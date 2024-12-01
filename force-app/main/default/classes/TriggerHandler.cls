public abstract class TriggerHandler {
    
    protected TriggerOperation operationType;
    protected Map<Id, SObject> oldMap;
    protected List<SObject> oldList;
    protected Map<Id, SObject> newMap;
    protected List<SObject> newList;

    public TriggerHandler() {
        this.operationType = Trigger.operationType;
        this.oldMap = Trigger.oldMap;
        this.oldList = Trigger.old;
        this.newMap = Trigger.newMap;
        this.newList = Trigger.new;
    }

    public void handle() {
        switch on operationType {
            when BEFORE_INSERT { this.beforeInsert(); }
            when AFTER_INSERT { this.afterInsert(); }
            when BEFORE_UPDATE { this.beforeUpdate(); }
            when AFTER_UPDATE { this.afterUpdate(); }
            when BEFORE_DELETE { this.beforeDelete(); }
            when AFTER_DELETE { this.afterDelete(); }
            when AFTER_UNDELETE { this.afterUndelete(); }
        }
    }

    protected virtual void beforeInsert() { }
    protected virtual void afterInsert() { }
    protected virtual void beforeUpdate() { }
    protected virtual void afterUpdate() { }
    protected virtual void beforeDelete() { }
    protected virtual void afterDelete() { }
    protected virtual void afterUndelete() { }
}