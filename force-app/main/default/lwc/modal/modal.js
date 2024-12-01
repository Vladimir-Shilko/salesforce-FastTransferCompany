import { LightningElement } from 'lwc';

export default class Modal extends LightningElement {
    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}
