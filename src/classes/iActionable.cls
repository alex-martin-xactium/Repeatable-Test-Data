/**
* @description Provides an interface for actionable classes that can be used by the ordered
*			   execution framework. With the ability to provide parameters and an execution context
*			   to assist with the execution of the action.
**/
public interface iActionable {

	/**
	* @description Provides a generic way to pass information into a instance of a
	*			   iActionable class, which can then be used to help carryout the
	*			   action when execute is called.
	* @param key - identifier for the parameter
	* @param value - the value for the parameter
	**/
	void addParam(String key, Object value);
	
	/**
	* @description execute method that must be provided by each class implementing this interface
	*			   to enable the ordered execution framework to execute code in the actionable class.
	* @param executionContext - instance of an execution context
	**/
	void execute(ExecutionContext executionContext);

}
