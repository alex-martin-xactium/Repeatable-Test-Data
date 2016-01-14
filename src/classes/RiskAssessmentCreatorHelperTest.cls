@isTest public with sharing class RiskAssessmentCreatorHelperTest {
	
	@isTest static void testCreateRiskAssessment() {
		
		Id ssId = ScoringSchemeHelper.createScoringScheme(null, null, null);
		
		grc__Business_Unit__c parent = new grc__Business_Unit__c();
		parent.Name = 'parent';
		parent.Risk__Sharing_Group_Name__c = 'parent';	
		parent.Risk__Scoring_Scheme__c = ssId;
		
		User usr = [Select Id from User where Id = :UserInfo.getUserId()];
		System.RunAs(usr)
		{
			Test.startTest();
			insert new List<grc__Business_Unit__c> { parent };
			Test.stopTest();
		}
		
		grc__Risk__c risk = new grc__Risk__c();
		risk.Name = 'risk1';
		risk.grc__Business_Unit__c = parent.Id;
		
		insert risk; 
		
		/****** Data created ********/
		
		List<Risk__Risk_Assessment__c> assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(null);
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('No parameters passed', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>>());
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('No parameters passed', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>> { 'x' => new List<String> { 'hooha' } });
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('Parameters should appear in the following format: residual => likelihood:2', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>> { 'residual' => new List<String> { 'hooha' } });
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('Parameters should appear in the following format: residual => likelihood:2', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>> { 'residual' => new List<String> { 'likelihood:66', 'cost:2', 'time:3' } });
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('The Score Band Entry value is larger than the scoring scheme size', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>> { 'residual' => new List<String> { 'likelihood:x', 'cost:y', 'time:c' } });
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('Score Band Entry value is not an integer', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());		
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>> { 'residual' => new List<String> { 'likelihood:1', 'cost:66', 'time:3' } });
			System.assert(false, 'Exception should be thrown');
		} catch(BadParameterException bp ) {
			System.assertEquals('The Score Band Entry value is larger than the scoring scheme size', bp.getMessage());
		} catch(Exception e) {
			System.assert(false, 'Wrong type of exception thrown' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}
		
		assessmentList = [Select Id from Risk__Risk_Assessment__c];
		System.assertEquals(0, assessmentList.size());		
		
		try {
			RiskAssessmentCreatorHelper.createRiskAssessment(new Map<String, List<String>> { 'residual' => new List<String> { 'likelihood:1', 'Cost:2', 'Time:3' } });
			Risk__Risk_Assessment__c assessment = [Select Id, Name, (Select Id, Name, Risk__Mitigation__c, Risk__Category__c, Risk__Impact_Category__c, Risk__Value__c, Risk__Best_Case__c, Risk__Worst_Case__c from Risk__Risk_Assessment_Ratings__r) from Risk__Risk_Assessment__c];
			System.assertEquals(3, assessment.Risk__Risk_Assessment_Ratings__r.size());
			
			integer costIC = 1;
			integer timeIC = 1;
			integer likelihood = 1;
			
			for(Risk__Risk_Assessment_Rating__c rating : assessment.Risk__Risk_Assessment_Ratings__r) {
				System.assertEquals('Residual', rating.Risk__Mitigation__c);
				if(rating.Risk__Category__c.equalsIgnoreCase('cost')) {
					costIC--;
					System.assertEquals(150.5,rating.Risk__Value__c);
					System.assertEquals(101,rating.Risk__Best_Case__c);
					System.assertEquals(200,rating.Risk__Worst_Case__c);					
				} else if(rating.Risk__Category__c.equalsIgnoreCase('time')) {
					timeIC--;
					System.assertEquals(2500.5,rating.Risk__Value__c);
					System.assertEquals(2001,rating.Risk__Best_Case__c);
					System.assertEquals(3000,rating.Risk__Worst_Case__c);					
				} else if(rating.Risk__Category__c.equalsIgnoreCase('Likelihood')) {
					likelihood--;
					System.assertEquals(5.5,rating.Risk__Value__c);
					System.assertEquals(1,rating.Risk__Best_Case__c);
					System.assertEquals(10,rating.Risk__Worst_Case__c);
				}
			}
			
			System.assertEquals(0, costIC);
			System.assertEquals(0, timeIC);
			System.assertEquals(0, likelihood);
			
		} catch(Exception e) {
			System.assert(false, 'Wasn\'t expecting an exception' + e.getMessage() + ' :: ' + e.getStackTraceString());
		}		
		
	}
	
}
