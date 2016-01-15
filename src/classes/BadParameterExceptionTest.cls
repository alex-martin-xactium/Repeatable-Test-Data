@isTest
public with sharing class BadParameterExceptionTest {
	@isTest static void testBadParameterException() {
		System.assertEquals('Record Creator', new BadParameterException().getProductArea(), 'Wrong product area');
	}
}
