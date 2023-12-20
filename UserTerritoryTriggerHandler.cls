public class UserTerritoryTriggerHandler {
    private Map<String, String> territoryToQueue = new Map<String, String>{
        'ATL' => 'Payer - ATL',
        'CHI' => 'Payer - CHI',
        'PHX' => 'Payer - PHX',
        'Duarte' => 'Payer - Duarte',
        'National' => 'Payer - National'
    };

    public void handleAfterInsert(List<UserTerritory2Association> newAssociations) {
        processUserTerritoryAssociations(newAssociations, true);
    }

    public void handleAfterUpdate(List<UserTerritory2Association> updatedAssociations, Map<Id, UserTerritory2Association> oldAssociationMap) {
        processUpdatedUserTerritoryAssociations(updatedAssociations, oldAssociationMap);
    }

    public void handleAfterDelete(List<UserTerritory2Association> oldAssociations) {
        processUserTerritoryAssociations(oldAssociations, false);
    }

    private void processUserTerritoryAssociations(List<UserTerritory2Association> associations, Boolean isInsert) {
        Map<Id, Set<String>> userToTerritories = new Map<Id, Set<String>>();
        List<GroupMember> groupMembersToAdd = new List<GroupMember>();
        Set<Id> groupMembersToRemove = new Set<Id>();

        Set<Id> territoryIds = new Set<Id>();
        for(UserTerritory2Association uta : associations) {
            territoryIds.add(uta.Territory2Id);
        }

        Map<Id, String> territoryIdToName = new Map<Id, String>();
        for (Territory2 terr : [SELECT Id, Name FROM Territory2 WHERE Id IN :territoryIds]) {
            territoryIdToName.put(terr.Id, terr.Name);
        }

        for(UserTerritory2Association uta : associations) {
            String territoryName = territoryIdToName.get(uta.Territory2Id);
            updateTerritoriesMap(userToTerritories, uta.UserId, territoryName, isInsert);

            if(uta.RoleInTerritory2 == 'Admin') {
                processQueueMembers(uta.UserId, territoryName, groupMembersToAdd, groupMembersToRemove, isInsert);
            }
        }
        
		system.debug('groupMembersToAdd: '+groupMembersToAdd);
        system.debug('groupMembersToRemove: '+groupMembersToRemove);
        system.debug('userToTerritories: '+userToTerritories);
        updateQueueMembers(groupMembersToAdd, groupMembersToRemove);
        updateQueueMembers(groupMembersToAdd, groupMembersToRemove);
        updateUsersTerritoryAssociations(userToTerritories);
    }

    private void processUpdatedUserTerritoryAssociations(List<UserTerritory2Association> updatedAssociations, Map<Id, UserTerritory2Association> oldAssociationMap) {
        Map<Id, Set<String>> userToTerritories = new Map<Id, Set<String>>();
        List<GroupMember> groupMembersToAdd = new List<GroupMember>();
        Set<Id> groupMembersToRemove = new Set<Id>();
    
        Set<Id> territoryIds = new Set<Id>();
        for(UserTerritory2Association uta : updatedAssociations) {
            territoryIds.add(uta.Territory2Id);
        }
    
        Map<Id, String> territoryIdToName = new Map<Id, String>();
        for (Territory2 terr : [SELECT Id, Name FROM Territory2 WHERE Id IN :territoryIds]) {
            territoryIdToName.put(terr.Id, terr.Name);
        }
    
        for(UserTerritory2Association updatedAssoc : updatedAssociations) {
            UserTerritory2Association oldAssoc = oldAssociationMap.get(updatedAssoc.Id);
    
            if(oldAssoc == null) {
                continue;
            }
    
            String territoryName = territoryIdToName.get(updatedAssoc.Territory2Id);
            updateTerritoriesMap(userToTerritories, updatedAssoc.UserId, territoryName, true);
    
            if(updatedAssoc.RoleInTerritory2 == 'Admin' && oldAssoc.RoleInTerritory2 != 'Admin') {
                processQueueMembers(updatedAssoc.UserId, territoryName, groupMembersToAdd, groupMembersToRemove, true);
            } else if(updatedAssoc.RoleInTerritory2 != 'Admin' && oldAssoc.RoleInTerritory2 == 'Admin') {
                processQueueMembers(updatedAssoc.UserId, territoryName, groupMembersToAdd, groupMembersToRemove, false);
            }
        }
        
    	system.debug('groupMembersToAdd: '+groupMembersToAdd);
        system.debug('groupMembersToRemove: '+groupMembersToRemove);
        system.debug('userToTerritories: '+userToTerritories);
        updateQueueMembers(groupMembersToAdd, groupMembersToRemove);
        updateUsersTerritoryAssociations(userToTerritories);
    }


    private void processQueueMembers(Id userId, String territoryName, List<GroupMember> groupMembersToAdd, Set<Id> groupMembersToRemove, Boolean isInsert) {
        Map<String, Id> queueNameToId = new Map<String, Id>();
        for(Group queue : [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Name IN :territoryToQueue.values()]) {
            queueNameToId.put(queue.Name, queue.Id);
        }

        if(territoryName == 'All Locations') {
            for(Id queueId : queueNameToId.values()) {
                if(isInsert) {
                    groupMembersToAdd.add(new GroupMember(GroupId = queueId, UserOrGroupId = userId));
                } else {
                    groupMembersToRemove.addAll(getGroupMemberIds(userId, queueId));
                }
            }
        } else {
            Id queueId = queueNameToId.get(territoryToQueue.get(territoryName));
            if(queueId != null) {
                if(isInsert) {
                    groupMembersToAdd.add(new GroupMember(GroupId = queueId, UserOrGroupId = userId));
                } else {
                    groupMembersToRemove.addAll(getGroupMemberIds(userId, queueId));
                }
            }
        }
    }

    private Set<Id> getGroupMemberIds(Id userId, Id queueId) {
        Set<Id> groupMemberIds = new Set<Id>();
        for(GroupMember gm : [SELECT Id FROM GroupMember WHERE UserOrGroupId = :userId AND GroupId = :queueId]) {
            groupMemberIds.add(gm.Id);
        }
        return groupMemberIds;
    }

    private void updateQueueMembers(List<GroupMember> groupMembersToAdd, Set<Id> groupMembersToRemove) {
        if(!groupMembersToAdd.isEmpty()) {
            insert groupMembersToAdd;
        }
        if(!groupMembersToRemove.isEmpty()) {
            delete [SELECT Id FROM GroupMember WHERE Id IN :groupMembersToRemove];
        }
    }

    private void updateTerritoriesMap(Map<Id, Set<String>> userToTerritories, Id userId, String territoryName, Boolean isInsert) {
        if(!userToTerritories.containsKey(userId)) {
            userToTerritories.put(userId, new Set<String>());
        }
        if(isInsert) {
            userToTerritories.get(userId).add(territoryName);
        } else {
            userToTerritories.get(userId).remove(territoryName);
        }
    }

    private void updateUsersTerritoryAssociations(Map<Id, Set<String>> userToTerritories) {
        List<User> usersToUpdate = new List<User>();
        for(Id userId : userToTerritories.keySet()) {
            String territories = String.join(new List<String>(userToTerritories.get(userId)), ';');
            usersToUpdate.add(new User(Id = userId, Territory_Associations__c = territories));
        }
        if(!usersToUpdate.isEmpty()) {
            update usersToUpdate;
        }
    }
}
