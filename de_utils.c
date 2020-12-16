#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
    // TODO: if we omit inline assembly:  store_idt(&tmpidtr);
    //asm volatile("sidt %0" : "=m"(idtr));
    //__asm__ __volatile__ ("sidt %0;" : "=m"(idtr));
    asm volatile ("sidt %0" : "=m" (*idtr));
}

void my_load_idt(struct desc_ptr *idtr) {
    // if we omit inline assembly: load_idt(addr);
    //asm volatile( "lidt %0" : : "m"(idtr));
    //__asm__ __volatile__ ("lidt %[idtptr];" : :[idtptr]"m"(idtr));
    asm volatile ("lidt %0" : "=m" (*idtr));
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
    //pack_gate(gate, GATE_INTERRUPT, addr, 0, 0, __KERNEL_CS);
    gate->offset_low = ((unsigned long long)(addr) & 0xFFFF);
    gate->segment = __KERNEL_CS;
    gate->bits.ist = 0;
    gate->bits.p = 1;
    gate->bits.dpl = 0;
    gate->bits.zero = 0;
    gate->bits.type = GATE_INTERRUPT;
    gate->offset_middle = (((unsigned long long)(addr) >> 16) & 0xFFFF);
    gate->offset_high = ((unsigned long long)(addr) >> 32);
}

unsigned long my_get_gate_offset(gate_desc *gate) {
    //return gate_offset(gate);
    return (gate->offset_low | (unsigned long)gate->offset_middle << 16 | (unsigned long)gate->offset_high << 32);
}