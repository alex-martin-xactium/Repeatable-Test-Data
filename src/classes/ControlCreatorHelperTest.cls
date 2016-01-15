@isTest
public with sharing class ControlCreatorHelperTest {
	@isTest static void testCreateControls() {
		grc__Business_Unit__c parent = new grc__Business_Unit__c();
		parent.Name = 'parent';
		parent.Risk__Sharing_Group_Name__c = 'parent';
		
		grc__Business_Unit__c parent1 = new grc__Business_Unit__c();
		parent1.Name = 'parent1';
		parent1.Risk__Sharing_Group_Name__c = 'parent1';	
		
		User usr = [Select Id from User where Id = :UserInfo.getUserId()];
		System.RunAs(usr)
		{
			Test.startTest();
			insert new List<grc__Business_Unit__c> { parent, parent1 };
			Test.stopTest();
		}	
		
		grc__Risk__c risk1 = new grc__Risk__c();
		risk1.Name = 'risk1'; 
		risk1.grc__Business_Unit__c = parent.Id;
		
		grc__Risk__c risk2 = new grc__Risk__c();
		risk2.Name = 'risk2'; 
		risk2.grc__Business_Unit__c = parent1.Id;		
		
		insert new List<grc__Risk__c> { risk1, risk2 };
		
		//Poorly formatted
		try {
			ControlCreatorHelper.createControls(null);
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed', e.getMessage(), 'Wrong Exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong Exception thrown: ' + e.getMessage());
		}
		//Poorly formatted
		try {
			ControlCreatorHelper.createControls(new Map<String, String>());
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameters passed', e.getMessage(), 'Wrong Exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong Exception thrown: ' + e.getMessage());
		}
		//Poorly formatted
		try {
			ControlCreatorHelper.createControls(new Map<String, String> { 'x' => 'x' });
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('No business units found', e.getMessage(), 'Wrong Exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong Exception thrown: ' + e.getMessage());
		}
		//Poorly formatted
		try {
			ControlCreatorHelper.createControls(new Map<String, String> { 'parent' => 'x' });
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Incorrect parameter format', e.getMessage(), 'Wrong Exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong Exception thrown: ' + e.getMessage());
		}
		//Poorly formatted
		try {
			ControlCreatorHelper.createControls(new Map<String, String> { 'parent' => 'control1:badrisk' });
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('No risks found', e.getMessage(), 'Wrong Exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong Exception thrown: ' + e.getMessage());
		}
		//good
		ControlCreatorHelper.createControls(new Map<String, String> { 'parent' => 'control1:risk1' });
		
		List<grc__Control__c> controls = [Select Id, Name, grc__Business_Unit__c from grc__Control__c];
		System.assertEquals(1, controls.size());
		System.assertEquals('control1', controls.get(0).Name);
		
		List<Risk__Risk_Control_Lookup__c> lookups = [Select Id, Risk__Risk__c, Risk__Control__c from Risk__Risk_Control_Lookup__c];
		System.assertEquals(1, lookups.size());
		System.assertEquals(risk1.Id, lookups.get(0).Risk__Risk__c);
		System.assertEquals(controls.get(0).Id, lookups.get(0).Risk__Control__c);
		System.assertEquals(parent.Id, controls.get(0).grc__Business_Unit__c);
		
		//good
		try {
			ControlCreatorHelper.createControls(new Map<String, String> { 'parent' => 'control1:risk1', 'x' => 'control2:risk1' });
			System.assert(false, 'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Business unit does not exist: x', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Expected an exception');
		}
		
		//good
		try {
			ControlCreatorHelper.createControls(new Map<String, String> { 'parent' => 'control1:risk1', 'parent1' => 'control2:xxx' });
			System.assert(false, 'Expected an exception');
		} catch(BadParameterException e) {
			System.assertEquals('Junction object cannot be created, risks or controls don\'t exist', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Expected an exception');
		}				
	}
}
