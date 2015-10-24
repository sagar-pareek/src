@isTest
public class ObjectMockerTest 
{
    public static TestMethod void testMocker()
    {
        SObject leadMock = ObjectMocker.mock('Lead');
        SObject userMock = ObjectMocker.mock('User');
        
        System.assertEquals('TEST', leadMock.get('LastName'));
        System.assertEquals('TEST', userMock.get('LastName'));
    }
}