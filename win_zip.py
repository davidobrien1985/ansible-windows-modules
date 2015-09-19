#!/usr/bin/python
# -*- coding: utf-8 -*-

# (c) 2015, David O'Brien <david.obrien@versent.com.au>
#
# This file is part of Ansible
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# this is a windows documentation stub.  actual code lives in the .ps1
# file of the same name

DOCUMENTATION = '''
---
module: win_zip
version_added: "0.1"
short_description: Zips files and folders on the Windows node
description:
     - This module will accept the source parameter which can be a file or a folder and use that information to compress
       the source to the destination parameter. If the destination zip file already exists and the force parameter was not provided, Ansible will rename the
       zip file to the bak extension in the same location. If force has been provided the existing zip file will be overwritten.
       Currently this module only supports local destinations, no UNC paths.
options:
    src:
        description:
            - This is the full local path to either a file or a folder that is supposed to be compressed into a zip container.
        required: true
        default: null
        aliases: []
    dest:
        description:
            - This is the full local path where the zip container is supposed to be created at.
        required: true
        default: null
        aliases: []
    force:
        description:
            - If force (bool) is specified, then the module will overwrite an existing zip file (dest parameter). If it is not specified then an already existing zip file
             will be renamed with a bak extension.
        required: false
        default: null
        aliases: []
author: "David O'Brien (obrien.david@outlook.com) @david_obrien"
'''

EXAMPLES = '''
# Compress a single file, do not overwrite existing foo.zip. Will result in existing foo.zip to be renamed to foo.bak
- win_copy: src=C:\\folder\\foo.bar dest=c:\\TEMP\\foo.zip
# Compress a folder, overwrite an existing foo.zip.
- win_copy: src=C:\\folder dest=c:\\TEMP\\foo.zip force=true
'''
