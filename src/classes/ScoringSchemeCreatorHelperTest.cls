@isTest public with sharing class ScoringSchemeCreatorHelperTest {
	
	@isTest static void testBlankCreateScoringScheme() {
		List<Risk__Scoring_Scheme__c> ss = [Select Id from Risk__Scoring_Scheme__c];
		System.assertEquals(0, ss.size(), 'Scoring scheme already exists');
		
		ScoringSchemeCreatorHelper.createScoringScheme(null, null, null);
		
		ss = [Select Id from Risk__Scoring_Scheme__c];
		System.assertNotEquals(null, ss, 'Scoring Scheme doesnt exist');
		
		List<Risk__Impact_Category__c> icList = [Select Id, Name, Risk__Type_Of_Risk__c from Risk__Impact_Category__c];
		System.assertEquals(2, icList.size());
		
		Risk__Impact_Category__c ic1 = icList.get(0);
		Risk__Impact_Category__c ic2 = icList.get(1);
		
		List<Risk__Score_Band__c> scoreBandList = [Select Id, Name, Risk__Type__c, Risk__Colour__c from Risk__Score_Band__c];
		System.assertEquals(10, scoreBandList.size());
		
		integer likelihoodBands = 5;
		integer impactBands = 5;
		Set<String> coloursUsed = new Set<String>();
		for(Risk__Score_Band__c sb : scoreBandList) {
			if(sb.Risk__Type__c == 'Likelihood') {
				likelihoodBands--;
				coloursUsed.add(sb.Risk__Colour__c);
			} else if(sb.Risk__Type__c == 'Impact') {
				impactBands--;
				coloursUsed.add(sb.Risk__Colour__c);
			}
		}
		
		System.assertEquals(0, likelihoodBands);
		System.assertEquals(0, impactBands);
		System.assertEquals(5, coloursUsed.size()); //make sure there's at least 5 unique colours.
		
		List<Risk__Score_Band_Entry__c> scoreBandEntries = [Select Id, Risk__Impact_Category__c from Risk__Score_Band_Entry__c];
		System.assertEquals(15, scoreBandEntries.size());
		
		integer likel = 5;
		integer cost = 5;
		integer timeIC = 5;
		
		for(Risk__Score_Band_Entry__c sbe : scoreBandEntries) {
			if(sbe.Risk__Impact_Category__c == null) {
				likel--;
			} else if(sbe.Risk__Impact_Category__c == ic1.Id) {
				if(ic1.Risk__Type_of_Risk__c == 'Cost') {
					cost--;
				} else if(ic1.Risk__Type_of_Risk__c == 'Time') {
					timeIC--;
				}
			} else if(sbe.Risk__Impact_Category__c == ic2.Id) {
				if(ic2.Risk__Type_of_Risk__c == 'Time') {
					timeIC--;
				} else if(ic2.Risk__Type_of_Risk__c == 'Cost') {
					cost--;
				}
			}
		}
		
		System.assertEquals(0, likel);
		System.assertEquals(0, cost);
		System.assertEquals(0, timeIC);		
		
		//Quick check that we have some semblance of a heatmap. 
		List<Risk__Rating_Info__c> ratingInfoList = [Select Id from Risk__Rating_Info__c where Risk__Colour__c != null AND Risk__Overall_rating__c != null];
		System.assertEquals(25, ratingInfoList.size());
	}
	
	@isTest static void test3x3CreateScoringScheme() {
		List<Risk__Scoring_Scheme__c> ss = [Select Id from Risk__Scoring_Scheme__c];
		System.assertEquals(0, ss.size(), 'Scoring scheme already exists');
		
		ScoringSchemeCreatorHelper.createScoringScheme(null, new List<String> { 'low', 'med', 'high' }, new List<String> { 'Lime Green', 'Green', 'Yellow' });
		
		ss = [Select Id from Risk__Scoring_Scheme__c];
		System.assertNotEquals(null, ss, 'Scoring Scheme doesnt exist');
		
		List<Risk__Impact_Category__c> icList = [Select Id, Name, Risk__Type_Of_Risk__c from Risk__Impact_Category__c];
		System.assertEquals(2, icList.size());
		
		Risk__Impact_Category__c ic1 = icList.get(0);
		Risk__Impact_Category__c ic2 = icList.get(1);
		
		List<Risk__Score_Band__c> scoreBandList = [Select Id, Name, Risk__Type__c, Risk__Colour__c from Risk__Score_Band__c];
		System.assertEquals(6, scoreBandList.size());
		
		integer likelihoodBands = 3;
		integer impactBands = 3;
		Set<String> coloursUsed = new Set<String>();
		for(Risk__Score_Band__c sb : scoreBandList) {
			if(sb.Risk__Type__c == 'Likelihood') {
				likelihoodBands--;
				coloursUsed.add(sb.Risk__Colour__c);
			} else if(sb.Risk__Type__c == 'Impact') {
				impactBands--;
				coloursUsed.add(sb.Risk__Colour__c);
			}
		}
		
		System.assertEquals(0, likelihoodBands);
		System.assertEquals(0, impactBands);
		System.assertEquals(3, coloursUsed.size()); //make sure there's at least 5 unique colours.
		
		List<Risk__Score_Band_Entry__c> scoreBandEntries = [Select Id, Risk__Impact_Category__c from Risk__Score_Band_Entry__c];
		System.assertEquals(9, scoreBandEntries.size());
		
		integer likel = 3;
		integer cost = 3;
		integer timeIC = 3;
		
		for(Risk__Score_Band_Entry__c sbe : scoreBandEntries) {
			if(sbe.Risk__Impact_Category__c == null) {
				likel--;
			} else if(sbe.Risk__Impact_Category__c == ic1.Id) {
				if(ic1.Risk__Type_of_Risk__c == 'Cost') {
					cost--;
				} else if(ic1.Risk__Type_of_Risk__c == 'Time') {
					timeIC--;
				}
			} else if(sbe.Risk__Impact_Category__c == ic2.Id) {
				if(ic2.Risk__Type_of_Risk__c == 'Time') {
					timeIC--;
				} else if(ic2.Risk__Type_of_Risk__c == 'Cost') {
					cost--;
				}
			}
		}
		
		System.assertEquals(0, likel);
		System.assertEquals(0, cost);
		System.assertEquals(0, timeIC);
		
		//Quick check that we have some semblance of a heatmap. 
		List<Risk__Rating_Info__c> ratingInfoList = [Select Id from Risk__Rating_Info__c where Risk__Colour__c != null AND Risk__Overall_rating__c != null];
		System.assertEquals(9, ratingInfoList.size());
	}	
}
