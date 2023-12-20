trigger UserTerritoryAssociationTrigger on UserTerritory2Association (after insert, after update, after delete) {
    UserTerritoryTriggerHandler handler = new UserTerritoryTriggerHandler();

    if(Trigger.isInsert) {
        handler.handleAfterInsert(Trigger.new);
    }

    if(Trigger.isUpdate) {
        system.debug('After update'+Trigger.new);
        handler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }

    if(Trigger.isDelete) {
        handler.handleAfterDelete(Trigger.old);
    }
}
