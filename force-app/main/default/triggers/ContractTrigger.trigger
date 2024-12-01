trigger ContractTrigger on Contract (after insert) {
    (new ContractTriggerHandler()).handle();
}