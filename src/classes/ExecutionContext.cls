/**
* @description Holds details about the execution in order to provide the necessary context when
*			   dealing with any execution of an actionable class.
**/
public with sharing class ExecutionContext {
	
	public Id recordId {get;set;}
	
	public ExecutionContext() {
		
	}
	
	public ExecutionContext(Id recordId) {
		this.recordId = recordId;
	}
	
}
