@isTest
public with sharing class RiskCreatorHelperTest {
	@isTest static void testCreateRisks() {
		
		grc__Business_Unit__c parent = new grc__Business_Unit__c();
		parent.Name = 'parent';
		parent.Risk__Sharing_Group_Name__c = 'parent';	
		
		User usr = [Select Id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            Test.startTest();
            insert new List<grc__Business_Unit__c> { parent };
            Test.stopTest();
        }		
		
		//Try bad parameters
		try {
			RiskCreatorHelper.createRisks(null);
			System.assert(false, 'Exception expected');
		} catch(BadParameterException e) {
			System.assertEquals('No parameters passed', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		
		//Try bad parameters
		try {
			RiskCreatorHelper.createRisks(new Map<String, String>());
			System.assert(false, 'Exception expected');
		} catch(BadParameterException e) {
			System.assertEquals('No parameters passed', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		//Try non-existant BU
		//
		try {
			RiskCreatorHelper.createRisks(new Map<String, String> { 'x' => 'x' });
			System.assert(false, 'Exception expected');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed. Created risks does not match risks to insert', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		
		try {
			RiskCreatorHelper.createRisks(new Map<String, String> { 'x' => null });
			System.assert(false, 'Exception expected');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed. Either Risk Name is Business Unit name is null', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}	
		
		try {
			RiskCreatorHelper.createRisks(new Map<String, String> { null => 'x' });
			System.assert(false, 'Exception expected');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed. Either Risk Name is Business Unit name is null', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}				
		
		System.assertEquals(0, [Select Id from grc__Risk__c].size());

		
		RiskCreatorHelper.createRisks(new Map<String, String> { 'risk1' => 'parent' });
		List<grc__Risk__c> risks = [Select ID, Name from grc__Risk__c];
		System.assertEquals(1, risks.size());
		System.assertEquals('risk1', risks.get(0).Name);
		
		RiskCreatorHelper.createRisks(new Map<String, String> { 'risk2' => 'parent', 'risk3' => 'parent' });
		risks = [Select ID, Name from grc__Risk__c];
		System.assertEquals(3, risks.size());
		
		for(grc__Risk__c risk : risks) {
			if(risk.Name == 'risk1' || risk.Name == 'risk2' || risk.Name == 'risk3') {
				continue;
			}
			System.assert(false, 'Wrong risk name');
		}

	}

}
