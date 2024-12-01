public class ScheduleTasksOverdue implements Schedulable{
	public void execute(SchedulableContext SC) {
        TaskOverdueNotificator batch = new TaskOverdueNotificator();
        Database.executeBatch(batch);
    }
}