/**
* @author Gary J Burgin
* @description This class is used to specialise the Exception class for the Product
*              DataGenerator.
**/
public virtual with sharing class DataGeneratorException extends Exception{

    public ApexPages.Severity severity {get;set;}

    public static final String QUERYLIMIT = 'Query Limits: ';
    public static final String DMLROWSLIMIT = 'DML Rows Limits: ';
    public static final String HEAPSIZELIMITS = 'Heap Size Limits: ';
    public static final String QUERYRETURNLIMITS = 'Query Return Limits: ';
    public static final String AGGQUERYLIMIT = 'Aggregate Query Limits: ';
    public static final String CALLOUTS = 'Callouts: ';
    public static final String CPUTIME = 'CPU Time: ';
    public static final String DMLSTMTS = 'DML Statements: ';
    public static final String FUTURECALLS = 'Future Calls: ';
    public static final String QUERYLOCATORROWS = 'Query Locator Rows: ';
    public static final String OUTOF = ' out of ';

    /**
    * @description This method returns the name of the product where this exception originated.
    * @return [String] returns the product name.
    **/
    public String getProductName(){
        return 'DataGenerator';
    }

    /**
    * @description This virtual method returns the area of the product where this exception originated.
    * @return [String] returns the product area, the default value is 'Unknown'.
    **/
    public virtual String getProductArea(){
        return 'Unknown';
    }

    /**
    * @description This virtual method returns the exception in a string format.
    * @return [String] returns the exception as a string.
    **/
    public virtual String getExceptionString(){
        return '\n\tProduct:  ' + this.getProductName() +
               '\n\tArea:  ' + this.getProductArea() +
               '\n\tType:  ' + (this.getTypeName() != null ? this.getTypeName() : 'Unknown') +
               '\n\tCause:  ' + (this.getCause() != null ? String.valueOf(this.getCause()) : 'Unknown') +
               '\n\tMessage:  ' + (this.getMessage() != null ? this.getMessage() : 'Unknown') +
               '\n\tStack Trace:  ' + (this.getStackTraceString() != null ? this.getStackTraceString() : 'Unknown');
    }

    /**
    * @description This method returns a page message constructed from the exception.
    * @return [ApexPages.Message] returns the exception as an ApexPages.Message.
    **/
    public ApexPages.Message getPageMessage(){
        return new ApexPages.Message((this.severity != null ? this.severity : ApexPages.Severity.INFO ), this.getMessage());
    }

    /**
    * @description This method adds a page message constructed from the exception to the ApexPages message list.
    **/
    public void addPageMessage(){
        ApexPages.addMessage(this.getPageMessage());
    }

    /**
    *   @author         Ashwin Srinivasan
    *   @description    This methods uses the Limits method in Salesforce to get the string containing 
    *                   lines for each of the execution limits with regards to the governor limits. 
    *                   Line 1: SOQL Queries, Line 2: No. of records count against DML, Line 3: Memory used(Heap), Line 4: Records returned by SOQL, 
    *                   Line 5: Aggregated Queries, Line 6: Number of webservices, Line 7: CPU Time (in milliseconds), 
    *                   Line 8: DML statements, Line 9: Future calls, Line 10: Rows returned by the Database.getQueryLocator method
    *   @return         String limitValue - return a string of listing a line for each limit and its current value at time of calling.
    *
    **/
    public string getLimitValue(){        
        String limitValue = '';
        limitValue += QUERYLIMIT+ Limits.getQueries() + OUTOF + Limits.getLimitQueries() +'\n';
        limitValue += DMLROWSLIMIT+ Limits.getDMLRows()+ OUTOF + Limits.getLimitDMLRows()+'\n';
        limitValue += HEAPSIZELIMITS+ Limits.getHeapSize()+ OUTOF +Limits.getLimitHeapSize()+'\n';
        limitValue += QUERYRETURNLIMITS+ Limits.getQueryRows()+ OUTOF + Limits.getLimitQueryRows()+'\n';
        limitValue += AGGQUERYLIMIT+ Limits.getAggregateQueries()+ OUTOF + Limits.getLimitAggregateQueries()+'\n';
        limitValue += CALLOUTS+ Limits.getCallouts()+ OUTOF +Limits.getLimitCallouts()+'\n';
        limitValue += CPUTIME+ Limits.getCpuTime()+ OUTOF +Limits.getLimitCpuTime()+'\n';
        limitValue += DMLSTMTS+ Limits.getDMLStatements()+ OUTOF +Limits.getLimitDMLStatements()+'\n';
        limitValue += FUTURECALLS+ Limits.getFutureCalls()+ OUTOF +Limits.getLimitFutureCalls()+'\n';
        limitValue += QUERYLOCATORROWS+ Limits.getQueryLocatorRows() + OUTOF +Limits.getLimitQueryLocatorRows()+'\n';
        return limitValue;        
    }
}
