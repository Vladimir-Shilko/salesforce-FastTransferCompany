public class TaskOverdueNotificator implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        RecordType requestedCallType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Requested_call' AND SObjectType = 'Task' LIMIT 1];

        return Database.getQueryLocator([
            SELECT Id, OwnerId 
            FROM Task 
            WHERE RecordTypeId = :requestedCallType.Id 
            AND Status = 'New' 
            AND ActivityDate < :Date.Today()
        ]);
    }

    public void execute(Database.BatchableContext bc, List<Task> scope) {
        CustomNotificationType notificationType = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName = 'TaskExpireNotification' LIMIT 1];

        String message = Label.TaskExpireLabel;
        List<Messaging.CustomNotification> notifications = new List<Messaging.CustomNotification>();

        for (Task task : scope) {
            String ownerId = task.OwnerId;
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle('Notification');
            notification.setBody(message);
            notification.setTargetId(task.Id);
            notification.setNotificationTypeId(notificationType.Id);
            notification.send(new Set<String>{ownerId});
            notifications.add(notification);
           
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}