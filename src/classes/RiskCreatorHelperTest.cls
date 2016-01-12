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
		RiskCreatorHelper.createRisks(null);
		//Try bad parameters
		RiskCreatorHelper.createRisks(new Map<String, String>());
		//Try bad parameters
		RiskCreatorHelper.createRisks(new Map<String, String> { 'badString' => 'another bad one' });
		//Try bad parameters
		RiskCreatorHelper.createRisks(new Map<String, String> { 'relationships' => 'another bad one' });
		//Good one
		System.assertEquals(0, [Select Id from grc__Risk__c].size());
		
		RiskCreatorHelper.createRisks(new Map<String, String> { 'relationships' => 'risk1:badBU' });
		System.assertEquals(0, [Select Id from grc__Risk__c].size());
		
		RiskCreatorHelper.createRisks(new Map<String, String> { 'relationships' => 'risk1:parent' });
		List<grc__Risk__c> risks = [Select ID, Name from grc__Risk__c];
		System.assertEquals(1, risks.size());
		System.assertEquals('risk1', risks.get(0).Name);
	}

}
