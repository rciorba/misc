/*
 * Copyright 2011 Benjamin Tissoires <benjamin.tissoi...@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License 
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Jim W's NOTE:
 *
 * Logitech don't provide a pairing utility for Linux.  Fortunately, someone
 * else wrote this one.
 *
 * 	Invocation (as root): #	pair /dev/hidrawN
 *
 * You can discover the value of N by "ls /dev/hidraw*" before and after
 * plugging in the nano receiver.  In the second invocation, your device
 * will be listed.
 */

#include <linux/input.h>
#include <linux/hidraw.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#define USB_VENDOR_ID_LOGITECH                  (__u32)0x046d
#define USB_DEVICE_ID_UNIFYING_RECEIVER         (__s16)0xc52b
#define USB_DEVICE_ID_UNIFYING_RECEIVER_2       (__s16)0xc532

int fd = -1;			/* File descriptor for raw HID device */
char magic_sequence[] = {	/* Say the magic word, */
  0x10, 0xFF, 0x80, 0xB2,	/*   win $100! */
  0x01, 0x00, 0x00, };


int cleanup(char* s) { perror(s); if (fd >= 0) close(fd); return -1; }


int main(int argc, char *argv[]) {

  if (argc == 1) { 
    errno = EINVAL; 
    return cleanup("No HID raw device specified");
  }

  /* Open raw Human-Interface Device with non-blocking reads.
   */
  if ((fd = open(argv[1], O_RDWR|O_NONBLOCK )) < 0)
    return cleanup("Unable to open raw HID device");

  /* Get Raw Device Info and check for Logitech.
   */
  int res; struct hidraw_devinfo info;	/* Result value, structure */

  if ((res = ioctl(fd, HIDIOCGRAWINFO, &info)) < 0)
    return cleanup("Can't get info from device");
  
  if (info.bustype != BUS_USB || info.vendor != USB_VENDOR_ID_LOGITECH
      /* || (info.product != USB_DEVICE_ID_UNIFYING_RECEIVER && */
      /*  info.product != USB_DEVICE_ID_UNIFYING_RECEIVER_2) */
      ) {
    errno = EPERM; return cleanup("Device isn't Logitech Unifying Receiver"); 
  }

  /* Send magic sequence to the Device
   */
  if ((res = write(fd, magic_sequence, sizeof(magic_sequence))) < 0 ||
       res != sizeof(magic_sequence)) return cleanup("write");

  printf("Receiver ready to pair. Switch your device on.\n"); 

  close(fd); return 0; 
}
