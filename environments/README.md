## Environments
### Important to understand

The default environment file is called:

**vagrant.json**

The other two json files are for **example only**:

**staging.json**

**production.json**

**DO NOT** use the *staging.json* or *production.json* in your environment **UNTIL** you modify them to fit your actual environment. Of course, you can rename and/or add others - it's completely up to you.

The environment file(s) overrides the default variable data found in the cookbook/chef-bcs/attributes directory. The default.rb contains the cookbook wide defaults and other specific .rb files contain variables specific to a given recipe.

If the default variable is acceptable then there is no need to override it in the environment file so it can be omitted.

The simplest way to look at these environment json files is to think of them as overlays. They simply overlay (take precedence) to any existing default that they represent.

### BTW

The data in the vagrant.json used for building a 3 node Ceph cluster plus 1 bootstrap (build) node is just an example to show that you can mix and match overrides and format the json data using any style you like as long as it's valid json.
