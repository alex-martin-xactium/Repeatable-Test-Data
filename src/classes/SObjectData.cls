public with sharing class SObjectData {
	private Map<String, Object> fieldMap = new Map<String, Object>();
	private String sObjectType;
	private Map<String, List<SObjectData>> children;
	private SObjectData parent;
	private String parentField;
	
	public SObjectData(String sobjectType) {
		this.sObjectType = sobjectType;
	}
	
	public SObjectData(String sobjectType, SObjectData parent) {
		this.sObjectType = sobjectType;
		setParent(parent);
	}
	
	public SObjectData(String sobjectType, Map<String, List<SObjectData>> children) {
		this.sObjectType = sobjectType;
		setChildren(children);
	}
	
	public SObjectData(String sobjectType, SObjectData parent, Map<String, List<SObjectData>> children) {
		this.sObjectType = sobjectType;
		setChildren(children);
		setParent(parent);
	}	
	
	public void setParent(SObjectData o) {
		parent = o;
	}
	
	public void setChildren(Map<String, List<SObjectData>> children) {
			this.children = children;
	}
	
	public void addChild(SObjectData o) {
		addChild(parentField, o);
	}
	
	public void addChild(String field, SObjectData o) {
		if(children == null) {
			children = new Map<String, List<SObjectData>>();
		}
		
		field = field.toLowerCase();
		
		if(children.containsKey(field)) {
			children.get(field).add(o);
		} else {
			children.put(field, new List<SObjectData> { o });
		}
	}	
	
	public void setParentField(String field) { 
		parentField = field;
		if(children != null && children.containsKey(null)) {
			List<SObjectData> buffer = children.get(null);
			children.remove(null);
			children.put(parentField, buffer);
		}
	}
	
	public String getParentField() {
		return parentField;
	}
	
	public void addValuePair(String field, Object value) {
		//TODO: Validation to ensure the value type is compatible with the field
		if(fieldMap ==null) {
			fieldMap = new Map<String, Object>();
		}
		fieldMap.put(field, value);
	}
	
	public Map<String, Object> getFieldMap() {
		return fieldMap;
	}
	
	public String getSObjectType() {
		return sObjectType;
	}
	
	public Map<String, List<SObjectData>> getChildren() {
		if(children == null) { 
			children = new Map<String, List<SObjectData>>();
		}
		return children;
	}
	
	public SObjectData getParent() {
		return parent;
	}
	
	//commit can't be used :(
	public void create() {
		SObjectUtility su = new SObjectUtility();
		su.createSObjects(new List<SObjectData> { this });		
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
