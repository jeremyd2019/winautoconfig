#!/usr/bin/env python

from github import Github, GithubIntegration, Consts, Installation, GithubObject
import github.Organization
import re
import requests
import sys

my_appid = 153139
my_keyfile = "msys2-arm.private-key.pem"
my_org = 'msys2-arm'

# stupid pygithub - https://github.com/PyGithub/PyGithub/issues/2117
def get_org_installation(self, org):
    """
    :calls: `GET /orgs/{org}/installation <https://docs.github.com/en/rest/reference/apps#get-an-organization-installation-for-the-authenticated-app>`_
    :param org: str
    :rtype: :class:`github.Installation.Installation`
    """
    headers = {
        "Authorization": f"Bearer {self.create_jwt()}",
        "Accept": Consts.mediaTypeIntegrationPreview,
        "User-Agent": "PyGithub/Python",
    }

    response = requests.get(
        f"{self.base_url}/orgs/{org}/installation",
        headers=headers,
    )
    response_dict = response.json()
    return Installation.Installation(None, headers, response_dict, True)

GithubIntegration.get_org_installation = get_org_installation

class RunnerToken(github.GithubObject.NonCompletableGithubObject):
    def __repr__(self):
        return self.get__repr__({"expires_at": self._expires_at.value})

    @property
    def token(self):
        """
        :type: string
        """
        return self._token.value

    @property
    def expires_at(self):
        """
        :type: datetime
        """
        return self._expires_at.value

    def _initAttributes(self):
        self._token = github.GithubObject.NotSet
        self._expires_at = github.GithubObject.NotSet

    def _useAttributes(self, attributes):
        if "token" in attributes:  # pragma no branch
            self._token = self._makeStringAttribute(attributes["token"])
        if "expires_at" in attributes:  # pragma no branch
            self._expires_at = self._makeDatetimeAttribute(
                re.sub(r'\.\d{3}Z$', 'Z', attributes["expires_at"])
            )


def get_self_hosted_runner_registration_token(self):
    """
    :calls: `POST /orgs/{owner}/actions/runners/registration-token <https://docs.github.com/en/rest/reference/actions#create-a-registration-token-for-an-organization>`_
    :rtype: :class:`RunnerToken`
    """
    headers, data = self._requester.requestJsonAndCheck(
        "POST", f"{self.url}/actions/runners/registration-token"
    )
    return RunnerToken(None, headers, data, True)

def get_self_hosted_runner_remove_token(self):
    """
    :calls: `POST /orgs/{owner}/actions/runners/remove-token <https://docs.github.com/en/rest/reference/actions#create-a-remove-token-for-an-organization>`_
    :rtype: :class:`RunnerToken`
    """
    headers, data = self._requester.requestJsonAndCheck(
        "POST", f"{self.url}/actions/runners/remove-token"
    )
    return RunnerToken(None, headers, data, True)

github.Organization.Organization.get_self_hosted_runner_registration_token = get_self_hosted_runner_registration_token
github.Organization.Organization.get_self_hosted_runner_remove_token = get_self_hosted_runner_remove_token
# END stupid pygithub

with open(my_keyfile, "r") as keyfile:
    key = keyfile.read()

integration = GithubIntegration(my_appid, key)
my_installation_id = integration.get_org_installation(my_org).id
installation_token = integration.get_access_token(my_installation_id)
print(installation_token.expires_at)
gh = Github(login_or_token=installation_token.token)
org = gh.get_organization(my_org)
reg_token = org.get_self_hosted_runner_registration_token()
with open("../setupscripts/vars.cmd.in", "r", newline='') as fi, \
     open("../setupscripts/vars.cmd", "w", newline='') as fo:
    for line in fi:
        fo.write(
                line.replace("@@@RUNNERREGURL@@@", org.html_url)
                    .replace("@@@RUNNERREGTOKEN@@@", reg_token.token))
