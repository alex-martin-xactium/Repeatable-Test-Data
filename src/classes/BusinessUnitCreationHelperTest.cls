@isTest
public with sharing class BusinessUnitCreationHelperTest {
	@isTest static void testBusinessUnitCreation() {
		List<grc__Business_Unit__c> results;
		
		results = BusinessUnitCreationHelper.createBusinessUnits(null, null);
		System.assertNotEquals(null, results);
		System.assertEquals(0, results.size());
		
		results = BusinessUnitCreationHelper.createBusinessUnits(new List<String>(), null);
		System.assertNotEquals(null, results);
		System.assertEquals(0, results.size());		
		
		results = BusinessUnitCreationHelper.createBusinessUnits(new List<String> { 'Parent' }, null);
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals('Parent', results.get(0).Name);
		System.assertEquals('Parent', results.get(0).Risk__Sharing_Group_Name__c);
		System.assertEquals(null, results.get(0).Risk__Scoring_Scheme__c);
		
		results = BusinessUnitCreationHelper.createBusinessUnits(new List<String> { 'Parent' }, '01p58000000nl6e');
		System.assertNotEquals(null, results);
		System.assertEquals(1, results.size());
		System.assertEquals('Parent', results.get(0).Name);
		System.assertEquals('Parent', results.get(0).Risk__Sharing_Group_Name__c);
		System.assertEquals('01p58000000nl6e', results.get(0).Risk__Scoring_Scheme__c);		
	}
}
