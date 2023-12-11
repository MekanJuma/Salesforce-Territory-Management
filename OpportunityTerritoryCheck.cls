trigger OpportunityTerritoryCheck on Opportunity (before delete) {
    Id payerOppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Payer').getRecordTypeId();

    for (Opportunity opp : Trigger.old) {
        if (opp.RecordTypeId != payerOppRecordTypeId) {
            continue;
        }

        Payer_Settings__c adminSetting = Payer_Settings__c.getInstance(UserInfo.getProfileId());

        if (adminSetting == null) {
            List<UserTerritory2Association> userTerritories = [
                SELECT Territory2.Name, RoleInTerritory2 
                FROM UserTerritory2Association 
                WHERE UserId = :UserInfo.getUserId()
            ];

            boolean hasAccess = false;
            for (UserTerritory2Association uta : userTerritories) {
                if (opp.Market__c == uta.Territory2.Name || uta.RoleInTerritory2 == 'Admin') {
                    hasAccess = true;
                    break;
                }
            }

            if (!hasAccess) {
                opp.addError('You do not have access to delete the opportunity in ' + opp.Market__c);
            }
        }
    }
}