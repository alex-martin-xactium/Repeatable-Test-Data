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
		
		try {
			ScoringSchemeCreatorHelper.createScoringScheme(null, new List<String> { 'low', 'med', 'high', 'bad' }, new List<String> { 'Lime Green', 'Green', 'Yellow' });
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('There are more score bands than colours', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		
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
		System.assertEquals(3, coloursUsed.size()); //make sure there's at least 3 unique colours.
		
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
	
	/**
	 * @description Heatmap can only support up to 5x5 at the moment. Defaults extra cells to colour black
	 */
	@isTest static void test6x6CreateScoringScheme() {
		List<Risk__Scoring_Scheme__c> ss = [Select Id from Risk__Scoring_Scheme__c];
		System.assertEquals(0, ss.size(), 'Scoring scheme already exists');
		
		try {
			ScoringSchemeCreatorHelper.createScoringScheme(null, new List<String> { 'low', 'med', 'high', 'bad' }, new List<String> { 'Lime Green', 'Green', 'Yellow' });
			System.assert(false, 'Expecting an exception');
		} catch(BadParameterException e) {
			System.assertEquals('There are more score bands than colours', e.getMessage(), 'Wrong exception thrown');
		} catch(Exception e) {
			System.assert(false, 'Wrong exception thrown');
		}
		
		ScoringSchemeCreatorHelper.createScoringScheme(null, new List<String> { 'low', 'med', 'high', 'extra1', 'extra2', 'extra3' }, new List<String> { 'Lime Green', 'Green', 'Yellow', 'Lime Green', 'Green', 'Yellow' });
		
		ss = [Select Id from Risk__Scoring_Scheme__c];
		System.assertNotEquals(null, ss, 'Scoring Scheme doesnt exist');
		
		List<Risk__Impact_Category__c> icList = [Select Id, Name, Risk__Type_Of_Risk__c from Risk__Impact_Category__c];
		System.assertEquals(2, icList.size());
		
		Risk__Impact_Category__c ic1 = icList.get(0);
		Risk__Impact_Category__c ic2 = icList.get(1);
		
		List<Risk__Score_Band__c> scoreBandList = [Select Id, Name, Risk__Type__c, Risk__Colour__c from Risk__Score_Band__c];
		System.assertEquals(12, scoreBandList.size());
		
		integer likelihoodBands = 6;
		integer impactBands = 6;
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
		System.assertEquals(3, coloursUsed.size()); //make sure there's at least 3 unique colours. 
		
		List<Risk__Score_Band_Entry__c> scoreBandEntries = [Select Id, Risk__Impact_Category__c from Risk__Score_Band_Entry__c];
		System.assertEquals(18, scoreBandEntries.size());
		
		integer likel = 6;
		integer cost = 6;
		integer timeIC = 6;
		
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
		List<Risk__Rating_Info__c> ratingInfoList = [Select Id, Risk__Colour__c from Risk__Rating_Info__c where Risk__Colour__c != null AND Risk__Overall_rating__c != null];
		Map<String, Integer> numberofHeatmapColours = new Map<String, Integer>();
		
		System.assertEquals(36, ratingInfoList.size());
		
		for(Risk__Rating_Info__c ratingInfo : ratingInfoList) {
			if(numberOfHeatmapColours.containsKey(ratingInfo.Risk__Colour__c)) {
				Integer n = numberOfHeatmapColours.get(ratingInfo.Risk__Colour__c);
				n++;
				numberOfHeatmapColours.put(ratingInfo.Risk__Colour__c, n);
			} else {
				numberOfHeatmapColours.put(ratingInfo.Risk__Colour__c, 1);
			}
		}
		
		/*
		This is the Heatmap currently being used as the default
		if(heatmap == null) {
			heatmap = new List<List<String>>();
			heatmap.add(new List<String> { '#A1FB41', '#59E817', '#00A000', '#F7FE2E', '#F7FE2E' });
			heatmap.add(new List<String> { '#59E817', '#00A000', '#F7FE2E', '#F7FE2E', '#FDD017' });
			heatmap.add(new List<String> { '#00A000', '#F7FE2E', '#F7FE2E', '#FDD017', '#FDD017' });
			heatmap.add(new List<String> { '#F7FE2E', '#F7FE2E', '#FDD017', '#FDD017', '#F62817' });
			heatmap.add(new List<String> { '#000000', '#FDD017', '#FDD017', '#F62817', '#F62817' });		
		} 
		Because our scoring scheme is 6x6, there should be lots more blacks. 
		 */
		
		System.assertEquals(7, numberOfHeatmapColours.keySet().size(), 'Wrong number of colours');
		
		for(String colour : numberOfHeatmapColours.keySet()) {
			if(colour.equalsIgnoreCase('#A1FB41')) {
				System.assertEquals(1, numberOfHeatmapColours.get(colour), 'Wrong number of Lime green');
			} else if(colour.equalsIgnoreCase('#59E817')) {
				System.assertEquals(2, numberOfHeatmapColours.get(colour), 'Wrong number of Light green');
			} else if(colour.equalsIgnoreCase('#00A000')) {
				System.assertEquals(3, numberOfHeatmapColours.get(colour), 'Wrong number of Dark green');
			} else if(colour.equalsIgnoreCase('#F7FE2E')) {
				System.assertEquals(8, numberOfHeatmapColours.get(colour), 'Wrong number of yellow');
			} else if(colour.equalsIgnoreCase('#000000')) {
				System.assertEquals(12, numberOfHeatmapColours.get(colour), 'Wrong number of blacks');
			} else if(colour.equalsIgnoreCase('#FDD017')) {
				System.assertEquals(7, numberOfHeatmapColours.get(colour), 'Wrong number of oranges');
			} else if(colour.equalsIgnoreCase('#F62817')) {
				System.assertEquals(3, numberOfHeatmapColours.get(colour), 'Wrong number of reds');
			}
		}
	}		
}
