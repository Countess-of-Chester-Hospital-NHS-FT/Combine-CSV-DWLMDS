# Open Code Checklist
This checklist is adapted from the [NHSE Repo Template](https://github.com/nhsengland/nhse-repository-template/blob/main/OPEN_CODE_CHECKLIST.md)
Please use this checklist to document adherence to best practice for published projects.

## When publishing your code you need to make sure:
  
### you’re clear about who owns the code and how others can use it

- [x] Does your code have an appropriate licence and copyright notice?
- [x] Is there a clear and concise README and does it document intended purpose?
- [x] The output of this project is not a medical device according to MHRA 'software as a medical device' regulation? (use [flowchart](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/999908/Software_flow_chart_Ed_1-08b-IVD.pdf))
- [ ] Are package dependencies and libaries documented with versions?

### You do not release information that should remain closed (in either source code, commits, discussions, outputs or documentation, now or at any time in the git history)

- [x] The repo does not include any sensitive, personal, secret or top secret data/information? 
- [x] The repo does not include any unreleased policy? 
- [x] The repo does not include business sensitive algorithms (e.g. finance allocations)? 
- [x] The repo does not include any credentials, keys or passwords?
- [x] The repo does not include any SQL server addresses or connection strings in the source code? 
- [x] The repo does not include notebooks, or the strategy for removing outputs from notebooks is detailed in the README (e.g using nbstripout).
- [ ] Is configuration written as code and separated from analytical code? 
- [x] The repo does not contain any screenshots or figures in outputs and documentation that contain information that shouldn't be released? 

### Any third-party tools you use to host or manage your code follow the National Cyber Security Centre’s cloud security guidance

- [x] No third party tools are used within the code (apart from GitHub or PyPI)? 

### An internal code review has been completed

- [x] Has the code been reviewed for sensitive data content and security vulnerabilities?
