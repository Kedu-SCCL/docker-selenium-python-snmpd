from selenium import webdriver
options = webdriver.ChromeOptions()
options.add_argument('headless')
capabilities = {}
capabilities.update(options.to_capabilities())
driver = webdriver.Remote(command_executor = 'http://selenium:4444/wd/hub', desired_capabilities = capabilities)
driver.get('https://www.fsf.org')
print driver.current_url
