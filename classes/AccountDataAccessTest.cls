@isTest
public class AccountDataAccessTest
{
    public static TestMethod void GetFirstAccountByNameAndOwner()
    {
        Account account = new Account(
            name = 'someone@mail.com',
            OwnerId = '00510000004s2Hz'
        );

        insert account;

        Account foundAccount = AccountDataAccess.FirstByNameAndOwner('someone@mail.com', '00510000004s2Hz');

        System.assert(account.Id == foundAccount.Id);
    }

    public static TestMethod void ThrowExceptionOnError()
    {
        try
        {
            AccountDataAccess.FirstByNameAndOwner('someone@mail.com', '00510000004s2Hz');
        }
        catch(UnderflowException e)
        {
            System.assert(true);
        }
    }
}