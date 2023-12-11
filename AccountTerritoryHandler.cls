public class AccountTerritoryHandler {
    
	public static void validateTerritory(List<Account> accounts) {
        Id payerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        Set<String> territoryNames = new Set<String>();
        
        for(Account acc : accounts) {
            if (acc.RecordTypeId == payerRecordTypeId && String.isNotBlank(acc.Territory__c)) {
                for(String territory : acc.Territory__c.split(';')) {
                    territoryNames.add(territory.trim());
                }
            }
        }
        
        if (!territoryNames.isEmpty()) {
            User currentUser = [SELECT Id, (SELECT Territory2Id FROM UserTerritory2Associations) FROM User WHERE Id = :UserInfo.getUserId()];
            
            Set<Id> userTerritoryIds = new Set<Id>();
            for (UserTerritory2Association assoc : currentUser.UserTerritory2Associations) {
                userTerritoryIds.add(assoc.Territory2Id);
            }
            
            Map<String, Id> nameToTerritoryId = new Map<String, Id>();
            for (Territory2 terr : [SELECT Id, Name FROM Territory2 WHERE Name IN :territoryNames]) {
                nameToTerritoryId.put(terr.Name, terr.Id);
            }
            
            for (Account acc : accounts) {
                if (acc.RecordTypeId == payerRecordTypeId) {
                    List<String> accountTerritories = acc.Territory__c.split(';');
                    for(String territory : accountTerritories) {
                        Id territoryId = nameToTerritoryId.get(territory.trim());
                        if (territoryId == null || !userTerritoryIds.contains(territoryId)) {
                            acc.addError('You don\'t have an access to this territory: ' + territory);
                        }
                    }
                }
            }
        }
    }

    
    public static void assignTerritory(List<Account> accounts) {
        Id payerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payer').getRecordTypeId();
        
        Set<String> territoryNames = new Set<String>();
        Map<Id, List<String>> accountIdToTerritoryNames = new Map<Id, List<String>>();
        
        for(Account acc : accounts) {
            if (acc.RecordTypeId == payerRecordTypeId && String.isNotBlank(acc.Territory__c)) {
                List<String> territories = new List<String>();
                for(String territory : acc.Territory__c.split(';')) {
                    territoryNames.add(territory.trim());
                    territories.add(territory.trim());
                }
                accountIdToTerritoryNames.put(acc.Id, territories);
            }
        }
        
        Map<String, Id> nameToTerritoryId = new Map<String, Id>();
        for (Territory2 terr : [SELECT Id, Name FROM Territory2 WHERE Name IN :territoryNames]) {
            nameToTerritoryId.put(terr.Name, terr.Id);
        }
        
        List<ObjectTerritory2Association> toInsert = new List<ObjectTerritory2Association>();
    
        List<ObjectTerritory2Association> existingAssociations = [SELECT Id FROM ObjectTerritory2Association WHERE ObjectId IN :accountIdToTerritoryNames.keySet()];
        if (!existingAssociations.isEmpty()) {
            delete existingAssociations;
        }
        
        for (Id accId : accountIdToTerritoryNames.keySet()) {
            List<String> territoryList = accountIdToTerritoryNames.get(accId);
            for(String territoryName : territoryList) {
                Id territoryId = nameToTerritoryId.get(territoryName);
                
                if (territoryId != null) {
                    ObjectTerritory2Association newAssociation = new ObjectTerritory2Association();
                    newAssociation.AssociationCause = 'Territory2Manual';
                    newAssociation.Territory2Id = territoryId;
                    newAssociation.ObjectId = accId; 
                    
                    toInsert.add(newAssociation);
                }
            }
        }
        
        if (!toInsert.isEmpty()) {
            insert toInsert;
        }
    }


}