---
title: "Effortless Package Management: A Comprehensive Look at APT"
date: 2025-03-14T00:02:13Z
draft: false
toc: false
images:
tags:
  - linux
---

You must’ve stumbled upon this command while reading online tutorials on how to install software, and we’ve all copy-pasted the command without a second thought because it works well most of the time and is an easy, convenient way to install/update software.
Today I’ll dive deeper on the intricacies of this command.

## What is APT Package Manager

The [Advanced Package Tool](https://en.wikipedia.org/wiki/APT_(software)) (APT) is a free utility that lets user install, update and manage software packages. These packages are bundled in repositories, which are external sources containing software that users can install. APT simplifies the interaction with these repositories and automates the management of dependencies.

APT came as a way to resolve dependency issues and is often hailed as one of Debian's best features.

### apt or apt-get? What's the difference?

#### A brief history

- ***apt-get*** was introduced in 1998 as part of the Advanced Package Tool (APT). It’s a low-level command-line utility that has been the backbone of package management for system administrators for over two decades. It provides powerful, granular control over installing, updating, and removing packages, making it ideal for scripting and automation.
- ***apt*** was introduced much later (in 2014 with Debian 8 and Ubuntu 16.04) as a more user-friendly interface that combines the most common functionalities of apt-get and apt-cache. It was designed to make package management simpler for everyday use by combining several commands into one and offering cleaner, more readable output.

In a general sense, we can qualify ***apt*** to be the summation of ***apt-get*** ***apt-cache*** and ***dpkg***.

{{< image src="/screens/apt-vs-aptget.png" alt="apt vs apt-get" position="center" style="border-radius: 8px; width: 50%" >}}

There are also a few differences in output between the two commands :

- ***apt*** is designed with a more user-friendly output. It includes:
  - Progress bars while downloading and installing packages.
  - Automatic interaction prompts for actions like confirmation before installing or removing packages.

{{< image src="/screens/apt_install.png" alt="apt install" position="center" style="border-radius: 8px;" >}}

***apt-get*** provides detailed and verbose output. It doesn’t automatically include prompts or progress bars unless specified. For example, if you’re scripting or working in environments where every bit of output and behavior matters, this detailed feedback can be useful.

{{< image src="/screens/apt_get_install.png" alt="apt install" position="center" style="border-radius: 8px;" >}}

## Common APT Commands

### Updating Repositories

You must've noticed that most commands/tutorial start with the following command :

```bash
sudo apt update
```

Before installing or upgrading any package, it's good practice to refresh the package database from the repositories using this command.

### Installing Packages

You can install packages using this well-known command :

```bash
sudo apt install package-name
```

You can install multiple packages by following this syntax :

```bash
sudo apt install package-1 package-2 package-3
```
___
*note : This syntax goes for installing, removing, purging...*
___
To install a specific version of a package, you can add the version following an "=" :


```bash
sudo apt install package-name=package_version
```

You can even easily install [.deb](https://en.wikipedia.org/wiki/Deb_(file_format)) packages :


```bash
sudo apt install ./debian-package.deb
```

### Removing Packages

Similarly to installing, removing packages is pretty straith foreward :


```bash
sudo apt remove package-name
```

You can use the *purge* command to remove packages along with their configuration files :


```bash
sudo apt purge package-name
```

### Upgrading Packages

You can have a full list of upgradable packages using this command :


```bash
sudo apt list --upgradable
```

{{< image src="/screens/screen_upgradable.png" alt="sudo apt list --upgradable" position="center" style="border-radius: 8px;" >}}

In my case, you can see that i have a handfull of packages that need upgrading, the nest step is to type in the following command :


```bash
sudo apt upgrade
```

For a more comprehensive upgrade; upgrading installed packages while also handling changes in dependencies, which may include removing existing packages if necessary :


```bash
sudo apt full-upgrade
```

If you do not want to remove packages, even if they're not needed anymore, you should use the following :


```bash
sudo apt dist-upgrade
```

___
*to learn more about the difference between **dist-upgrade** and **full-upgrade** you should check out [this article](https://hatchjs.com/apt-dist-upgrade-vs-full-upgrade/)*
___

You can upgrade a specific package if needed :


```bash
sudo apt upgrade package-name
```

## Managing repositories

A lot of beginners struggle to understand this part of the process and find themselves with errors or copy-pasting commands without understanding them.

For a more comprehensive understanding on the way we might add a third party repo to our system, I'll use the case of **mangoDB**. On their official website, we get told to follow these steps to install the community edition :

```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg \
   --dearmor

echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] \
   http://repo.mongodb.org/apt/debian bookworm/mongodb-org/8.0 main" | \
   sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
```

Let's break this down :

### First part

- **curl :** : A command-line tool used to download data from a URL. In this case, it is used to fetch the MongoDB GPG public key.
- **-fsSL** :
  - f : Fail silently on server errors. If the server returns a 404 (not found) or 500 (server error), curl will not output any errors to the terminal.
  - s : Silent mode. Suppresses progress meter and error messages. It’s useful when you don’t want verbose output, especially in scripts.
  - S : Show errors. If -s is used, this ensures that error messages will still be displayed. This prevents progress messages from showing, but actual errors (if any) will still be printed.
  - L : Follow redirects. If the URL redirects to another URL (like when you’re being redirected from HTTP to HTTPS), curl will follow it and fetch the final URL.

We fetch the PGP key from the link, and we pipe it into gpg :
- **gpg** : This is the GNU Privacy Guard, a tool used to encrypt and sign data, as well as manage public and private keys. In this case, it processes the downloaded PGP key.
- **-o** : To specify the output file.
- **--dearmor** : This converts the downloaded PGP key from its ASCII-armored format (text format, like .asc) into the binary format (like .gpg) that is more suitable for machine usage. "ASCII-armored" means the key is encoded in a text-based format, and *"dearmoring"* refers to converting it back into binary.

### Second part

- **deb** : This specifies that the repository is for binary (.deb) packages. APT uses this syntax to define repositories.
- ***[signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg]*** : This option tells APT that this repository’s packages are signed by a specific GPG key. It's located at /usr/share/keyrings/mongodb-server-8.0.gpg, which we obtained and placed there in the previous command using gpg --dearmor. This ensures that APT uses this key to verify the authenticity of packages downloaded from this repository.

Finally, we pipe the results into tee. That writes the APT repository definition to the */etc/apt/sources.list.d/* directory.

## More apt commands

And now, a list of apt commands that are lesser-known but that I find useful.

___
```bash
apt list --installed
```

Helps you quickly view all the installed packages without needing to search manually, you can even pip the output into grep to find a specific package(s) :

{{< image src="/screens/apt_grep_list.png" alt="apt list --installed" position="center" style="border-radius: 8px;" >}}
___
```bash
apt show package
```

Displays detailed information about a package, including its dependencies, description, and version.
___
```bash
apt depends package
```

Displays a list of dependencies for a package.


```bash
apt rdepends package
```

Lists all reverse dependencies, i.e., packages that depend on the specified package.
___

```bash
sudo apt-mark hold package
```

Prevents a package from being upgraded.

```bash
sudo apt-mark unhold package
```

Removes a hold on a package, allowing it to be upgraded again.
___
```bash
sudo apt autoremove
```

Removes unused packages. Add --purge to remove the configuration files too.

## Conclusion

In conclusion, APT is a powerful and essential tool for managing packages on Debian-based systems. Whether you're a beginner or an advanced user, understanding the nuances of APT and its various commands can greatly enhance your system administration skills.