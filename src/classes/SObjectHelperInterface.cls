public interface SObjectHelperInterface {

	List<Id> createSObjects(List<SObjectData> dataList);
	void insertSObjects(Map<String, SObject> objMap);
}
