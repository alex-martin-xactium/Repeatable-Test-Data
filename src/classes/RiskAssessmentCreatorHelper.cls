
public with sharing class RiskAssessmentCreatorHelper {
	
	//I need to know the risk name, multiple impact categories and their scores, likelihood and mitigation. 
	public static void createRiskAssessment() {
		
	}
	
	public static Risk__Risk_Assessment_Rating__c createAssessmentRating(Id riskAssessmentId, Risk__Impact_Category__c impactCategory, String mitigation ) {
		if(riskAssessmentId == null || mitigation == null || mitigation == '') {
			throw new BadParameterException('Incorrect parameters passed');
		}
		
		Risk__Risk_Assessment_Rating__c rating = new Risk__Risk_Assessment_Rating__c();
		rating.Risk__Risk_Assessment__c = riskAssessmentId;
		
		if(impactCategory != null) {
			rating.Risk__Impact_Category__c = impactCategory.Id;
			rating.Risk__Category__c = impactCategory.Name;
		} else {
			rating.Risk__Category__c = 'Likelihood';
		}
		
		return rating;
	}
}
