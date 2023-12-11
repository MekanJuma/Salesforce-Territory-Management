trigger AccountTerritoryAssignment on Account (before insert, before update, after insert, after update) {
    Payer_Settings__c adminSetting = Payer_Settings__c.getInstance(UserInfo.getProfileId());
    
    if (adminSetting == null) {
        if (Trigger.isBefore) {
            AccountTerritoryHandler.validateTerritory(Trigger.new);
        } else if (Trigger.isAfter) {
            AccountTerritoryHandler.assignTerritory(Trigger.new);
        }
    }
}