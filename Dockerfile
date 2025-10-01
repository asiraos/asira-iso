
FROM archlinux:latest

RUN pacman -Sy --noconfirm archiso

WORKDIR /build

COPY . .

RUN mkdir -p {out,work}

CMD ["mkarchiso", "-v", "-w", "work", "-o", "out", "."]
