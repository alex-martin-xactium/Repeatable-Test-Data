@isTest
public with sharing class BusinessUnitRelationshipHelperTest {
	@isTest static void testUpdateRelationships() {
		grc__Business_Unit__c parent = new grc__Business_Unit__c();
		parent.Name = 'parent';
		parent.Risk__Sharing_Group_Name__c = 'parent';
		
		grc__Business_Unit__c child1 = new grc__Business_Unit__c();
		child1.Name = 'child1';
		child1.Risk__Sharing_Group_Name__c = 'child1';
	
		grc__Business_Unit__c child2 = new grc__Business_Unit__c();
		child2.Name = 'child2';
		child2.Risk__Sharing_Group_Name__c = 'child2';
	
		grc__Business_Unit__c child11 = new grc__Business_Unit__c();
		child11.Name = 'child11';
		child11.Risk__Sharing_Group_Name__c = 'child11';
	
		grc__Business_Unit__c child21 = new grc__Business_Unit__c();
		child21.Name = 'child21';
		child21.Risk__Sharing_Group_Name__c = 'child21';	
		
		User usr = [Select Id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            Test.startTest();
            insert new List<grc__Business_Unit__c> { parent, child1, child2, child11, child21 };
            Test.stopTest();
        }
		
		Map<String, String> parameters = new Map<String, String>();
		parameters.put('child1', 'parent');
		parameters.put('child2', 'parent');
		parameters.put('child11', 'child1');
		parameters.put('child21', 'child2');
		
		List<grc__Business_Unit__c> results = new List<grc__Business_Unit__c>();
		
		//First test, no parameters.
		try {
			results = BusinessUnitRelationshipHelper.updateRelationships(null);
			System.assert(false,'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('No parameters passed', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false,'Expected an exception');
		}

		//Empty parameters
		try {
			results = BusinessUnitRelationshipHelper.updateRelationships(new Map<String, String>());
			System.assert(false,'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('No parameters passed', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false,'Expected an exception');
		}

		//wrong key test
		try {
			results = BusinessUnitRelationshipHelper.updateRelationships(new Map<String, String> { 'missing bu' => 'missing bu' });
			System.assert(false,'Expected an exception');         
		} catch(BadParameterException e) {
			System.assertEquals('Child or parent business unit don\'t exist', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false,'Expected an exception');
		}

		try {
			results = BusinessUnitRelationshipHelper.updateRelationships(new Map<String, String> { 'child1' => 'missing parent' }); 
			System.assert(false,'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Child or parent business unit don\'t exist', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false,'Expected an exception');
		}
		
		try {
			results = BusinessUnitRelationshipHelper.updateRelationships(new Map<String, String> { 'child1' => null }); 
			System.assert(false,'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed, child or parent is null', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false,'Expected an exception');
		}		

		try {
			results = BusinessUnitRelationshipHelper.updateRelationships(new Map<String, String> { 'missing child' => 'parent' });
			System.assert(false,'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Child or parent business unit don\'t exist', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false,'Expected an exception');
		}				

		results = BusinessUnitRelationshipHelper.updateRelationships(parameters);	
		
		System.assertNotEquals(null, results);
		//4 children, 2 to parent, 1 each to them. 
		System.assertEquals(4, results.size());
		
		for(grc__Business_Unit__c bu : results) {
			if(bu.Name == 'Child1' || bu.Name == 'Child2') {
				System.assertEquals(parent.Id, bu.grc__Parent_Business_Unit__c);
			} else if(bu.Name == 'Child11') {
				System.assertEquals(child1.Id, bu.grc__Parent_Business_Unit__c);
			} else if(bu.Name == 'Child21') {
				System.assertEquals(child2.Id, bu.grc__Parent_Business_Unit__c);
			}
		}
	}
}
