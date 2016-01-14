@isTest
public with sharing class BusinessUnitCreatorHelperTest {
	@isTest static void testBusinessUnitCreation() {
		List<grc__Business_Unit__c> results;
		
		results = BusinessUnitCreatorHelper.createBusinessUnits(null);
		System.assertNotEquals(null, results);
		System.assertEquals(0, results.size());
		
		results = BusinessUnitCreatorHelper.createBusinessUnits(new Map<Id, List<String>>());
		System.assertNotEquals(null, results);
		System.assertEquals(0, results.size());		
		
		results = BusinessUnitCreatorHelper.createBusinessUnits(new Map<Id, List<String>> { null => new List<String> { 'Parent' } });
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals('Parent', results.get(0).Name);
		System.assertEquals('Parent', results.get(0).Risk__Sharing_Group_Name__c);
		System.assertEquals(null, results.get(0).Risk__Scoring_Scheme__c);
		
		results = BusinessUnitCreatorHelper.createBusinessUnits(new Map<Id, List<String>> { '01p58000000nl6e' => new List<String> { 'Parent' } } );
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals('Parent', results.get(0).Name);
		System.assertEquals('Parent', results.get(0).Risk__Sharing_Group_Name__c);
		System.assertEquals('01p58000000nl6e', results.get(0).Risk__Scoring_Scheme__c);		
	}
}
