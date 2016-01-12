public with sharing class Sin {
    private static Sin classInstance;

    static {
        classInstance = new Sin();
    }

    private Sin() {
        
    }

    public static Sin getInstance() {
        return classInstance;
    }
}