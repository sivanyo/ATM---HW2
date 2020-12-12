#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
    // TODO: if we omit inline assembly:  store_idt(&tmpidtr);
    //asm volatile("sidt %0" : "=m"(idtr));
    __asm__ __volatile__ ("sidt %0"; : "=m"(idtr));
}

void my_load_idt(struct desc_ptr *idtr) {
    // if we omit inline assembly: load_idt(addr);
    //asm volatile( "lidt %0" : : "m"(idtr));
    __asm__ __volatile__ ("lidt %[idtptr]"; : :[idtptr]"m"(idtr));
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
    pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
}

unsigned long my_get_gate_offset(gate_desc *gate) {
    return gate_offset(gate);
}