@isTest
public class ContractTriggerTest {
    @isTest
    static void testContractTriggerAfterInsert() {
       
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        User testUser = new User(
            Username = 'testuserr56743@example.com',
            LastName = 'adad',
            Email = 'testuserr56743@example.com',
            Alias = 'test',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        Contract testContract = new Contract(
            AccountId = testAccount.Id,
            Shipping_CompanyUser__c = testUser.Id,
            Status = 'Draft'
        );
        Test.startTest();
        insert testContract;
        Test.stopTest();
        List<UserRecordAccess> a = null;
        try{
           a = [SELECT RecordID FROM UserRecordAccess WHERE UserId = :testUser.Id AND RecordID= :testContract.id AND HasEditAccess = True];  
        }
        catch(Exception e){}
        
        System.assertEquals(a.isEmpty(), false, 'Доступ к записи не найде');
       
        List<AccountShare> shares = [SELECT Id, AccountId, UserOrGroupId, AccountAccessLevel FROM AccountShare WHERE AccountId = :testAccount.Id AND UserOrGroupId = :testUser.Id];

      
        System.assertEquals(1, shares.size(), 'Требуется создать одну запись AccountShare');
        System.assertEquals(testAccount.Id, shares[0].AccountId, 'AccountId должен совпадать');
        System.assertEquals(testUser.Id, shares[0].UserOrGroupId, 'UserOrGroupId должен совпадать');
        System.assertEquals('Edit', shares[0].AccountAccessLevel, 'AccountAccessLevel должен быть "Edit"');
 
    }
}