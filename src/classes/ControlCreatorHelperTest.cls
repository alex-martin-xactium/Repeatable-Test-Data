@isTest
public with sharing class ControlCreatorHelperTest {
	@isTest static void testCreateControls() {
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
		
		grc__Risk__c risk1 = new grc__Risk__c();
		risk1.Name = 'risk1'; 
		risk1.grc__Business_Unit__c = parent.Id;
		
		insert risk1;
		
		ControlCreatorHelper.createControls(null, null);
		ControlCreatorHelper.createControls(new Map<String, String>(), null);
		ControlCreatorHelper.createControls(new Map<String, String> { 'x' => 'x' }, null);
		ControlCreatorHelper.createControls(new Map<String, String> { 'relationships' => 'x' }, parent.Id);
		ControlCreatorHelper.createControls(new Map<String, String> { 'relationships' => 'control1:risk1' }, parent.Id);
		
		List<grc__Control__c> controls = [Select Id, Name, grc__Business_Unit__c from grc__Control__c];
		System.assertEquals(1, controls.size());
		System.assertEquals('control1', controls.get(0).Name);
		
		List<Risk__Risk_Control_Lookup__c> lookups = [Select Id, Risk__Risk__c, Risk__Control__c from Risk__Risk_Control_Lookup__c];
		System.assertEquals(1, lookups.size());
		System.assertEquals(risk1.Id, lookups.get(0).Risk__Risk__c);
		System.assertEquals(controls.get(0).Id, lookups.get(0).Risk__Control__c);
		System.assertEquals(parent.Id, controls.get(0).grc__Business_Unit__c);
	}
}
