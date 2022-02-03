


build:
	nasm src/boot.s -o out/boot.bin
	nasm src/kernel.s -o out/kernel.bin -i src/
	dd if=/dev/zero of=out/stackos.img bs=1024 count=1440
	dd if=out/boot.bin of=out/stackos.img conv=notrunc
	dd if=out/kernel.bin of=out/stackos.img conv=notrunc seek=1

run: build
	qemu-system-x86_64 -drive format=raw,file=out/stackos.img -monitor stdio -serial file:out/log
	

clean:
	rm out/boot.bin
	rm out/stackos.img
