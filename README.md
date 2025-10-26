# grepcidr

**Version 3.0** - Filter IP addresses matching IPv4 and IPv6 CIDR specification

Parts Copyright (C) 2004-2005  Jem E. Berkes <jberkes@pc-tools.net>  
<http://www.pc-tools.net/unix/grepcidr/>

Revised by John Levine <johnl@taugh.com> Dec 2013-Oct 2015, who makes
no copyright claims to the modifications.

## PURPOSE

`grepcidr` can be used to filter a list of IP addresses against one or more
Classless Inter-Domain Routing (CIDR) specifications, or arbitrary networks
specified by an address range. As with grep, there are options to invert
matching and load patterns from a file. `grepcidr` is capable of comparing
thousands or even millions of IPs to networks with little memory usage and
in reasonable computation time.

`grepcidr` has endless uses in network software, including: mail filtering and
processing, network security, log analysis, and many custom applications.

## COMPILING & INSTALLING

Edit Makefile to customize the build. Then,

```bash
make
make install
```

## COMMAND USAGE

### Usage

```text
grepcidr [-V] [-cCDvhais] PATTERN [FILE ...]
grepcidr [-V] [-cCDvhaiso] [-e PATTERN | -f FILE] [FILE ...]
```

### Options

| Option | Description |
|--------|-------------|
| `-V` | Show software version |
| `-a` | Anchor matches to beginning of line, otherwise match anywhere |
| `-c` | Display count of the lines that would have been shown, instead of showing them |
| `-C` | Parse CIDR ranges in input and only match if a search term encompasses the entire range. |
| `-D` | Parse CIDR ranges in input and match if a search term matches any part of the range. |
| `-v` | Invert the sense of matching, to select non-matching IP addresses |
| `-e` | Specify pattern(s) on command-line |
| `-f` | Obtain CIDR and range pattern(s) from file |
| `-i` | Ignore patterns that are not valid CIDRs or ranges |
| `-h` | Do not print filenames when matching multiple files |
| `-o` | Print the matching pattern line instead of the input line. When overlapping patterns exist, prints the narrowest (most specific) match. |

### Pattern Format

`PATTERN` specified on the command line may contain multiple patterns
separated by whitespace or commas. For long lists of network patterns,
specify a `-f FILE` to load where each line contains one pattern. Comment
lines starting with `#` are ignored, as are comments following white space
after a pattern. Use `-i` to ignore invalid pattern lines.

Each pattern, whether on the command line or inside a file, may be:

| Format | Example |
|--------|---------|
| CIDR format | `a.b.c.d/xx` or `aa:bb::cc::dd/xx` |
| IP range | `a.b.c.d-e.f.g.h` |
| Single IP | `a.b.c.d` or `aa:bb:cc::dd` |

### IPv6 Support

IPv6 addresses can be written in any format including embedded IPv4.
The zero address `::` is accepted as a pattern but does not match in
files. (Use regular grep if that's what you're looking for.) It does
not accept IPv6 ranges, since few people use them.

### Performance

`grepcidr` uses a state machine to look for IP addresses in the input,
and a binary search to match addresses against patterns. Its speed is
roughly O(N) in the size of the input, and O(log N) in the number of
patterns.

**Pattern Optimization:** A prepass over the patterns merges adjacent
and overlapping patterns so there is negligible speed penalty for matching,
e.g. `1.2.2.0/24` and `1.2.3.0/24` rather than `1.2.2.0/23`.

**Narrowest Match Mode:** When the `-o` flag is used, pattern merging is
disabled to preserve all overlapping ranges. In this mode, a linear search
is performed to find the narrowest (most specific) matching pattern. For
example, if patterns include both `10.0.0.0/8` and `10.1.2.0/24`, an IP
like `10.1.2.50` will match the more specific `/24` range.

For **duplicate ranges** with identical CIDR specifications but different
labels (e.g., AWS ranges that appear as both `AMAZON` and `S3`), the last
occurrence in the file is returned, allowing more specific service
classifications to override generic ones. This is useful for identifying
the most specific network classification in overlapping CIDR lists.

Input files are mapped into memory if possible, so the state machine
can make one pass over the whole file. If mapping fails, it reads the
input a line at a time.

## EXAMPLES

**Find our customers that show up in blocklists:**

```bash
grepcidr -f ournetworks blocklist > abuse.log
```

**Searches for any localnet IP addresses inside the iplog file:**

```bash
grepcidr 127.0.0.0/8,::1 iplog
```

**Searches for IPs matching indicated range in the iplog file:**

```bash
grepcidr "192.168.0.1-192.168.10.13" iplog
```

**Create a blacklist, with whitelisted networks removed (inverse):**

```bash
script | grepcidr -ivf whitelist > blacklist
```

**Cross-reference two lists, outputs IPs common to both lists:**

```bash
grepcidr -if list1 list2
```

**Show which networks matched (print patterns instead of input lines):**

```bash
grepcidr -o -f networks.txt access.log
```

This outputs the matching CIDR pattern (e.g., `10.0.0.0/8`) instead of the original log line, useful for identifying which network ranges are hitting your service.
