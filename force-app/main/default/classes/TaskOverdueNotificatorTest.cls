@isTest
public class TaskOverdueNotificatorTest {

    @isTest(SeeAllData=True)
    static void testTaskOverdueNotificator() {
        RecordType requestedCallType = [SELECT Id FROM RecordType WHERE
            DeveloperName = 'Requested_call'];
        
        CustomNotificationType customNotificationType = [SELECT Id FROM  CustomNotificationType WHERE DeveloperName = 'TaskExpireNotification'];

        Task overdueTask = new Task(
            OwnerId = UserInfo.getUserId(),
            RecordTypeId = requestedCallType.Id,
            Status = 'New',
            ActivityDate = Date.today().addDays(-1)
        );
        insert overdueTask;

        Test.startTest();
        TaskOverdueNotificator batch = new TaskOverdueNotificator();
        Database.executeBatch(batch);
        Test.stopTest();
        

    }

    @isTest
    static void testScheduleTasksOverdue() {
       
        Test.startTest();
        ScheduleTasksOverdue scheduledJob = new ScheduleTasksOverdue();
        String cronExp = '0 0 22 * * ?';
		System.schedule('Notify Task Overdue', cronExp, scheduledJob);
        Test.stopTest();

        List<AsyncApexJob> jobs = [SELECT Id, ApexClassId, Status FROM AsyncApexJob WHERE ApexClass.Name = 'TaskOverdueNotificator'];
        System.assert(!jobs.isEmpty(), 'A batch job should have been enqueued.');
        System.assertEquals('Queued', jobs[0].Status, 'The batch job should be Queued.');
    }
}