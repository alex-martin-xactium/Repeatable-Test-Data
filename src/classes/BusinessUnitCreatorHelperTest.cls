@isTest
public with sharing class BusinessUnitCreatorHelperTest {
	@isTest static void testBusinessUnitCreation() {
		
		List<grc__Business_Unit__c> results;
		
		try {
			results = BusinessUnitCreatorHelper.createBusinessUnits(null);
			System.assert(false, 'Wrong exception thrown');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		
		try {
			results = BusinessUnitCreatorHelper.createBusinessUnits(new Map<String, List<String>>());
			System.assert(false, 'Wrong exception thrown');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		
		try {
			results = BusinessUnitCreatorHelper.createBusinessUnits(new Map<String, List<String>> { 'Scoring Scheme' => new List<String> { 'Parent' } });
			System.assert(false, 'Wrong exception thrown');
		} catch(BadParameterException e) {
			System.assertEquals('Scoring scheme not found', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}					

		BusinessUnitCreatorHelper.createBusinessUnits(new Map<String, List<String>> { null => new List<String> { 'Parent' } });
		results = [Select Id, Name, Risk__Sharing_Group_Name__c, Risk__Scoring_Scheme__c from grc__Business_Unit__c];
		System.assertEquals(1, results.size());
		System.assertEquals('Parent', results.get(0).Name);
		System.assertEquals('Parent', results.get(0).Risk__Sharing_Group_Name__c);
		System.assertEquals(null, results.get(0).Risk__Scoring_Scheme__c);
		
		Id ssId = ScoringSchemeCreatorHelper.createScoringScheme(null, null, null);
		
		User usr = [Select Id from User where Id = :UserInfo.getUserId()];
		System.RunAs(usr)
		{
			Test.startTest();
			results = BusinessUnitCreatorHelper.createBusinessUnits(new Map<String, List<String>> { 'Scoring Scheme' => new List<String> { 'Parent2' } } );
			Test.stopTest();
		}
		
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals('Parent2', results.get(0).Name);
		System.assertEquals('Parent2', results.get(0).Risk__Sharing_Group_Name__c);
		System.assertEquals(ssId, results.get(0).Risk__Scoring_Scheme__c);		
	}
}
