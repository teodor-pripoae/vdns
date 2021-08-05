module vdns

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>

struct C.addrinfo {
	ai_flags     int
	ai_family    int
	ai_socktype  int
	ai_protocol  int
	ai_addrlen   C.size_t
	ai_canonname &char
	ai_addr      &C.sockaddr
	ai_next      &C.addrinfo
}

struct C.sockaddr_in {
	sin_family i16
	sin_port   u16
	sin_addr   C.in_addr
	sin_zero   [8]char
}

fn C.inet_ntoa(&C.in_addr) &char
fn C.getaddrinfo(&char, &char, &C.addrinfo, &&C.addrinfo) int
fn C.getnameinfo(&C.sockaddr, u32, &char, u32, &char, u32, int) int
fn C.gai_strerror(int) &char
fn C.freeaddrinfo(&C.addrinfo)

fn unique_strings(strings []string) []string {
	mut unique := map[string]int{}
	for x in strings {
		unique[x] = 1
	}
	return unique.keys()
}

pub fn lookup_host(hostname string) ?[]string {
	result := &C.addrinfo(0)
	defer {
		C.freeaddrinfo(result)
	}

	s := C.getaddrinfo(&char(hostname.str), C.NULL, C.NULL, &result)

	if s != 0 {
		error_string := unsafe { cstring_to_vstring(C.gai_strerror(s)) }
		return error('Error from getaddrinfo: $error_string')
	}

	mut addresses := []string{}

	for rp := result; rp != C.NULL; rp = rp.ai_next {
		internet_addr := unsafe { &C.sockaddr_in(rp.ai_addr) }
		address := unsafe { cstring_to_vstring(C.inet_ntoa(internet_addr.sin_addr)) }
		addresses << address
	}

	addresses = unique_strings(addresses)
	addresses.sort()

	return addresses
}
