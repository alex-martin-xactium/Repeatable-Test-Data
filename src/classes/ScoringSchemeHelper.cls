/**
 * @description Scoring scheme helper that lets you create a dynamic scoring scheme.
 */
public with sharing class ScoringSchemeHelper {
	
	/**
	 * @description simple method to create the scoring scheme and insert it
	 * @param  Multidimensional array to represent the heatmap colours. 
	 * @param  Names of the scorebands. This also represents how many scorebands there should be. 
	 * @param  Score band colours. Index out of bands if this list if smaller than the scoreBandNames.
	 */
	public static void createScoringScheme(List<List<String>> heatmap, List<String> scoreBandNames, List<String> scoreBandColours) {
		Risk__Scoring_Scheme__c scoringScheme = new Risk__Scoring_Scheme__c();
		scoringScheme.Name = 'Scoring Scheme';
		scoringScheme.Risk__Multiply_Impact_Likelihood__c = true;
		
		//first insert, the scoring scheme. 
		insert scoringScheme;

		Risk__Impact_Category__c c = new Risk__Impact_Category__c();
		c.Risk__Type_of_Risk__c = 'Cost';
		c.Name = 'Cost';
		c.Risk__Scoring_Scheme__c = scoringScheme.Id;

		Risk__Impact_Category__c t = new Risk__Impact_Category__c();
		t.Risk__Type_of_Risk__c = 'Time';
		t.Name = 'Time';
		t.Risk__Scoring_Scheme__c = scoringScheme.Id;
		
		//then we insert the impact categories. 
		insert new List<Risk__Impact_Category__c> { c, t };
		
		integer numberOfScoreBands;
		//determine if custom score bands are defined, otherwise we use a default 5x5 grid 
		if(scoreBandNames ==null ) {
			scoreBandNames = new List<String> { 'V.Low', 'Low', 'Moderate', 'High', 'V.High' };
			numberOfScoreBands = 5;
		} else {
			numberOfScoreBands = scoreBandNames.size();
		}
		
		//check if custom score band colours are passed. If not, use predefined defaults. 
		if(scoreBandColours == null) {
			scoreBandColours = new List<String> { 'Lime Green', 'Green', 'Yellow', 'Orange', 'Red' };
		}
		List<Risk__Score_Band__c> scoreBands = new List<Risk__Score_Band__c>();
		List<Risk__Score_Band__c> impactScoreBands = new List<Risk__Score_Band__c>();
		List<Risk__Score_Band_Entry__c> scoreBandEntries = new List<Risk__Score_Band_Entry__c>();
		
		//dynamically create the correct number of scorebands.
		for(integer i = 0; i < numberOfScoreBands; i++) {
			Risk__Score_Band__c sb = new Risk__Score_Band__c();
			sb.Risk__Rating__c = i+1;
			sb.Risk__Type__c = 'Impact';
			sb.Name = scoreBandNames.get(i);
			sb.Risk__Colour__c = scoreBandColours.get(i);
			sb.Risk__Scoring_Scheme__c = scoringScheme.Id;
			
			Risk__Score_Band__c lsb = new Risk__Score_Band__c();
			lsb.Risk__Rating__c = i+1;
			lsb.Risk__Type__c = 'Likelihood';
			lsb.Name = scoreBandNames.get(i);
			lsb.Risk__Colour__c = scoreBandColours.get(i);
			lsb.Risk__Scoring_Scheme__c = scoringScheme.Id;
			impactScoreBands.add(sb);
			scoreBands.add(lsb);
		}
		
		//insert both lists. Could combine into one list?
		List<Risk__Score_Band__c> combinedScoreBands = new List<Risk__Score_Band__c>(scoreBands);
		combinedScoreBands.addAll(impactScoreBands);
		insert combinedScoreBands;
		
		for(Risk__Score_Band__c sb : combinedScoreBands) {
			
			if(sb.Risk__Type__c == 'Likelihood') {
				Risk__Score_Band_Entry__c sbe1 = new Risk__Score_Band_Entry__c();
				sbe1.Risk__From_Value__c = ((sb.Risk__Rating__c-1)*10)+1;
				sbe1.Risk__To_Value__c = (sb.Risk__Rating__c)*10;
				sbe1.Risk__Score_Band__c = sb.Id;
				
				scoreBandEntries.add(sbe1);
			} else {
				Risk__Score_Band_Entry__c sbe2 = new Risk__Score_Band_Entry__c();
				sbe2.Risk__From_Value__c = ((sb.Risk__Rating__c-1)*100)+1;
				sbe2.Risk__To_Value__c = (sb.Risk__Rating__c)*100;
	 			sbe2.Risk__Score_Band__c = sb.Id;	
				sbe2.Risk__Impact_Category__c = c.Id;
				
				Risk__Score_Band_Entry__c sbe3 = new Risk__Score_Band_Entry__c();
				sbe3.Risk__From_Value__c = ((sb.Risk__Rating__c-1)*1000)+1;
				sbe3.Risk__To_Value__c = (sb.Risk__Rating__c)*1000;
	 			sbe3.Risk__Score_Band__c = sb.Id;
				sbe3.Risk__Impact_Category__c = t.Id;
				
				scoreBandEntries.add(sbe2);
				scoreBandEntries.add(sbe3);					
			}			
		}
		
		insert scoreBandEntries;

		List<Risk__Rating_Info__c> ratingInfo = new List<Risk__Rating_Info__c>();
		
		
		//if a custom heatmap isn't specified, use the default.
		if(heatmap == null) {
			heatmap = new List<List<String>>();
			heatmap.add(new List<String> { '#A1FB41', '#59E817', '#00A000', '#F7FE2E', '#F7FE2E' });
			heatmap.add(new List<String> { '#59E817', '#00A000', '#F7FE2E', '#F7FE2E', '#FDD017' });
			heatmap.add(new List<String> { '#00A000', '#F7FE2E', '#F7FE2E', '#FDD017', '#FDD017' });
			heatmap.add(new List<String> { '#F7FE2E', '#F7FE2E', '#FDD017', '#FDD017', '#F62817' });
			heatmap.add(new List<String> { '#000000', '#FDD017', '#FDD017', '#F62817', '#F62817' });		
		} 
		
		//Build the rating info. it's the colours on the heatmap and the points for each cell.
		for(integer y = 0; y < impactScoreBands.size(); y++) {
			Risk__Score_Band__c isb = impactScoreBands.get(y);
			
		    for(integer x = 0; x < scoreBands.size(); x++) {
				Risk__Score_Band__c sb = scoreBands.get(x);
				
		        Risk__Rating_Info__c ri1 = new Risk__Rating_Info__c();
		        ri1.Risk__Colour__c = heatmap.get(y).get(x);
		        ri1.Risk__Impact__c = isb.Name;
		        ri1.Risk__Likelihood__c = sb.Name;
		        ri1.Risk__Impact_rating__c = isb.Risk__Rating__c;
		        ri1.Risk__Likelihood_Rating__c = sb.Risk__Rating__c;
		        ri1.Risk__Scoring_Scheme__c = scoringScheme.Id;
		        ri1.Risk__Overall_rating__c = isb.Risk__Rating__c * sb.Risk__Rating__c;

		        ratingInfo.add(ri1);
		    }
		}		
		insert ratingInfo;
	}
}
