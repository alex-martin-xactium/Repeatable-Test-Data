public with sharing class SObjectUtility {
	
	Map<String, Map<String, Map<String, SObject>>> childrenMap = new Map<String, Map<String, Map<String, SObject>>>();
	
	public List<Id> createSObjects(List<SObjectData> dataList) {
		Map<String, SObject> root = createRoot(dataList);
		insertSObjects(root);
		return null;
	}
	
	public SObject createSObject(SObjectData obj) {
		if(!Schema.getGlobalDescribe().containsKey(obj.getSObjectType())) {
			throw new AppException('Incorrect object type'); //TODO: use exception thingy
		}
		SObject sObj = Schema.getGlobalDescribe().get(obj.getSObjectType()).newSObject() ;
		for(String field : obj.getFieldMap().keySet()) {
			Object value = obj.getFieldMap().get(field);
			sObj.put(field, value);
		}
		
		return sObj;
	}

	public void insertSObjects(Map<String, SObject> objMap) {
		try {
			Map<String, SObject> childMap = new Map<String, SObject>();
			insert objMap.values();
			for(String key : objMap.keySet()) {
				for(String relationshipKey : childrenMap.keySet()) {
					
					if(childrenMap.get(relationshipKey).containsKey(key)) {
						childMap.putAll(buildRelationships(relationshipKey, objMap.get(key).Id, childrenMap.get(relationshipKey).get(key)));
					}					
				}

			}
			if(childMap.keySet().size() > 0) {
				insertSObjects(childMap);
			}
			
		} catch(Exception e) {
			throw new AppException(e.getMessage());
		}
		
	}
	
	public Map<String, SObject> buildRelationships(String field, String parentId, Map<String, SObject> objMap) {
		try {
			for(String key : objMap.keySet()) {
				objMap.get(key).put(field, parentId);
			}
			return objMap;
		} catch(Exception e) {
			throw new AppException(e.getMessage());
		}
	}	
	
	private Map<String, SObject> createRoot(List<SObjectData> dataList) {
		Map<String, SObject> rootObjects = new Map<String, SObject>();
		for(SObjectData obj : dataList) {
			String rId = generateRandomString(18);
			rootObjects.put(rId, createSObject(obj));
			if(obj.getChildren().size()>0) {
				createChildren(rId, obj.getChildren());
			}
		}
		return rootObjects;
	}
	
	private void createChildren(String parentId, Map<String, List<SObjectData>> childMap) {
		
		for(String relationshipKey : childMap.keySet()) {
			Map<String, SObject> childObjects = new Map<String, SObject>();
			List<SObjectData> childrenList = childMap.get(relationshipKey);
			
			for(SObjectData obj : childrenList) {
				String rId = generateRandomString(18);
				childObjects.put(rId, createSObject(obj));
				if(obj.getChildren().size() > 0) {
					createChildren(rId, obj.getChildren());
				}
			}	
			
			Map<String, Map<String, SObject>> bufferMap = new Map<String, Map<String, SObject>>();
			bufferMap.put(parentId, childObjects);
			if(childrenMap.containsKey(relationshipKey)) {
				childrenMap.get(relationshipKey).putAll(bufferMap);
			} else {
				childrenMap.put(relationshipKey, bufferMap);		
			}
			
		}		
	}
	
	public static String generateRandomString(Integer len) {
	    final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
	    String randStr = '';
	    while (randStr.length() < len) {
	       Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
	       randStr += chars.substring(idx, idx+1);
	    }
	    return randStr; 
	}	
}


/*	public static void create5x5ScoringScheme() {
	SObjectData scoringScheme = new SObjectData('Risk__Scoring_Scheme__c');
	scoringScheme.addValuePair('Name', 'Scoring Scheme 5x5');
	scoringScheme.addValuePair('RecordTypeId', '012580000000H5p');
	
	SObjectData costIC = new SObjectData('Risk__Impact_Category__c');
	costIC.addValuePair('Name', 'Cost IC');
	costIC.addValuePair('Risk__Type_Of_Risk__c', 'Cost');
	
	SObjectData timeIC = new SObjectData('Risk__Impact_Category__c');
	timeIC.addValuePair('Name', 'Time IC');	
	timeIC.addValuePair('Risk__Type_Of_Risk__c', 'Time');	
	
	scoringScheme.addChild('Risk__Scoring_Scheme__c', costIC);
	scoringScheme.addChild('Risk__Scoring_Scheme__c', timeIC);
	
	List<String> sbNames = new List<String> { 'V.Low', 'Low', 'Moderate', 'High', 'V.High' };
	List<String> colours = new List<String> { 'Lime Green', 'Green', 'Yellow', 'Orange', 'Red' };
	
	for(integer i = 0; i < 5; i++) {
		SObjectData sb = new SObjectData('Risk__Score_Band__c');
		sb.addValuePair('Risk__Rating__c', i+1);
		sb.addValuePair('Risk__Type__c', 'Impact');
		sb.addValuePair('Name', sbNames.get(i));
		sb.addValuePair('Risk__Colour__c', colours.get(i));
		scoringScheme.addChild('Risk__Scoring_Scheme__c', sb);
		
		SObjectData isb = new SObjectData('Risk__Score_Band__c');
		isb.addValuePair('Risk__Rating__c', i+1);
		isb.addValuePair('Risk__Type__c', 'Likelihood');
		isb.addValuePair('Name', sbNames.get(i));
		isb.addValuePair('Risk__Colour__c', colours.get(i));
		scoringScheme.addChild('Risk__Scoring_Scheme__c', isb);	
		
		/*
		Score_Band_Entry__c sbe3 = new Score_Band_Entry__c();
		sbe3.From_Value__c = 41;
		sbe3.To_Value__c = 60;
		sbe3.Score_Band__c = sb3.Id;			
		 */		
		/*
		SObjectData sbe1 = new SObjectData('Risk__Score_Band_Entry__c');
		sbe1.addValuePair('Risk__From_Value__c', i*10);
		sbe1.addValuePair('Risk__To_Value__c', i+1*10);
		isb.addChild('Risk__Score_Band__c', sbe1);
		
		SObjectData sbe2 = new SObjectData('Risk__Score_Band_Entry__c');
		sbe2.addValuePair('Risk__From_Value__c', i*100);
		sbe2.addValuePair('Risk__To_Value__c', i+1*100);
		costIC.addChild('Risk__Impact_Category__c', sbe2);
		sb.addChild('Risk__Score_Band__c', sbe2);	
		
		SObjectData sbe3 = new SObjectData('Risk__Score_Band_Entry__c');
		sbe3.addValuePair('Risk__From_Value__c', i*1000);
		sbe3.addValuePair('Risk__To_Value__c', i+1*1000);
		timeIC.addChild('Risk__Impact_Category__c', sbe3);
		sb.addChild('Risk__Score_Band__c', sbe3);						
	}

	
	scoringScheme.create();
}*/
