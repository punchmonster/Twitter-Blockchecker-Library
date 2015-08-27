# Twitter Blockchecker Library

### About

This repo is a module written in Lua for Lapis web server projects, allowing easy checking of Twitter blocklists from blocktogether.org defined in your configuration file.

### How do I get set up?

simply include it in your Lapis project like you would any other Lua module and then add the blocklists to your Lapis config file as shown below:
```lua
  -- stores the various blocktogether.org blocklist URLs
  blockURL = {
  	{ 
  		name = 'AutoBlocker',
  		url  ='https://blocktogether.org/show-blocks/5867111278318bd542293272f751f'
  	}
  	{ 
  		name = 'HaterBlocker',
  		url  ='https://blocktogether.org/show-blocks/4387489484448448448hjg4kig4lg'
  	}
  }
  }
})
```