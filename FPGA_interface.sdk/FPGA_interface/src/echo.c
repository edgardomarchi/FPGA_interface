/*
 * Copyright (C) 2016 - 2019 Xilinx, Inc.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. The name of the author may not be used to endorse or promote products
 *    derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
 * OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 *
 */

#include <stdio.h>
#include <string.h>

#include "lwip/sockets.h"
#include "netif/xadapter.h"
#include "lwipopts.h"
#include "xil_printf.h"
#include "FreeRTOS.h"
#include "task.h"
#include "platform_config.h"
#include "dma.h"
#include "xaxidma.h"

#define THREAD_STACKSIZE 2048

u16_t echo_port = 7;

extern XAxiDma dma;
extern u32 sharedToFPGABuffer[MAX_SIGNAL_LENGTH];		// DMA shared memory
extern u32 sharedFromFPGABuffer[MAX_SIGNAL_LENGTH];		// DMA shared memory
extern char send_buf[2048];  		// Send buffer
extern char recv_buf[2048];  		// Receive buffer

void print_echo_app_header()
{
    xil_printf("%20s %6d %s\r\n", "echo server",
                        echo_port,
                        "$ telnet <board_ip> 7");

}

/* thread spawned for each connection */
void process_echo_request(void *p)
{
	int sd = (int)p;
	int RECV_BUF_SIZE = 2048;
	//char recv_buf[RECV_BUF_SIZE];
	//char send_buf[RECV_BUF_SIZE];
	int n, nwrote;
	int i, j;	// iterators
	int status;

	while (1) {
		/* read a max of RECV_BUF_SIZE bytes from socket */
		if ((n = read(sd, recv_buf, RECV_BUF_SIZE)) < 0) {
			xil_printf("%s: error reading from socket %d, closing socket\r\n", __FUNCTION__, sd);
			break;
		}

		/* break if the recved message = "quit" */
		if (!strncmp(recv_buf, "quit", 4))
			break;

		/* break if client closed connection */
		if (n <= 0)
			break;

		/* handle request */
		// Convert 8 to 32 bits
		i=0;
		for (j=0; j<n/4; j++)
		{
			sharedToFPGABuffer[j] = (recv_buf[i+3] << 24) | (recv_buf[i+2] << 16) |
									(recv_buf[i+1] << 8)  | (recv_buf[i]);
			i=i+4;
			xil_printf("%x\n\r",sharedToFPGABuffer[j]);
		}
		// Send to DMA
		XAxiDma_IntrEnable(&dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DMA_TO_DEVICE);
    	status = XAxiDma_SimpleTransfer(&dma, (UINTPTR)sharedToFPGABuffer, n, XAXIDMA_DMA_TO_DEVICE);
    	if (status != XST_SUCCESS) {
    		xil_printf("WARNING: DMA RX failed!!!\n\r");
    	}
    	xil_printf("\n\r DMA transfer sent\n\r");


    	XAxiDma_IntrEnable(&dma, XAXIDMA_IRQ_ALL_MASK, XAXIDMA_DEVICE_TO_DMA);
    	status = XAxiDma_SimpleTransfer(&dma, (UINTPTR)sharedFromFPGABuffer, n, XAXIDMA_DEVICE_TO_DMA);
    	if (status != XST_SUCCESS) {
    		xil_printf("WARNING: DMA RX failed!!!\n\r");
    	}

    	for(i=0;i<(n/4);i++){
    		send_buf[(i*4)+0]= (char) (sharedFromFPGABuffer[i]>>24);
    		send_buf[(i*4)+1]= (char) (sharedFromFPGABuffer[i]>>16);
    		send_buf[(i*4)+2]= (char) (sharedFromFPGABuffer[i]>>8);
    		send_buf[(i*4)+3]= (char) (sharedFromFPGABuffer[i]);
    	}

		if ((nwrote = write(sd, recv_buf, n)) < 0) {
			xil_printf("%s: ERROR responding to client echo request. received = %d, written = %d\r\n",
					__FUNCTION__, n, nwrote);
			xil_printf("Closing socket %d\r\n", sd);
			break;
		}
	}

	/* close connection */
	close(sd);
	vTaskDelete(NULL);
}

void echo_application_thread()
{
	int sock, new_sd;
	int size;
#if LWIP_IPV6==0
	struct sockaddr_in address, remote;

	memset(&address, 0, sizeof(address));

	if ((sock = lwip_socket(AF_INET, SOCK_STREAM, 0)) < 0)
		return;

	address.sin_family = AF_INET;
	address.sin_port = htons(echo_port);
	address.sin_addr.s_addr = INADDR_ANY;
#else
	struct sockaddr_in6 address, remote;

	memset(&address, 0, sizeof(address));

	address.sin6_len = sizeof(address);
	address.sin6_family = AF_INET6;
	address.sin6_port = htons(echo_port);

	memset(&(address.sin6_addr), 0, sizeof(address.sin6_addr));

	if ((sock = lwip_socket(AF_INET6, SOCK_STREAM, 0)) < 0)
		return;
#endif

	if (lwip_bind(sock, (struct sockaddr *)&address, sizeof (address)) < 0)
		return;

	lwip_listen(sock, 0);

	size = sizeof(remote);

	while (1) {
		if ((new_sd = lwip_accept(sock, (struct sockaddr *)&remote, (socklen_t *)&size)) > 0)
		{
			sys_thread_new("echos", process_echo_request,
				(void*)new_sd,
				THREAD_STACKSIZE,
				DEFAULT_THREAD_PRIO);
		}
	}
}
