// SPDX-License-Identifier: MIT
package com.mercedesbenz.sechub.integrationtest.scenario9;

import static com.mercedesbenz.sechub.integrationtest.internal.IntegrationTestDefaultProfiles.*;

import com.mercedesbenz.sechub.integrationtest.api.TestProject;
import com.mercedesbenz.sechub.integrationtest.api.TestUser;
import com.mercedesbenz.sechub.integrationtest.internal.AbstractSecHubServerTestScenario;
import com.mercedesbenz.sechub.integrationtest.internal.CleanScenario;
import com.mercedesbenz.sechub.integrationtest.internal.IntegrationTestDefaultProfiles;
import com.mercedesbenz.sechub.integrationtest.internal.PDSTestScenario;

/**
 * <b><u>Scenario9 - the PDS integration test SARIF scenario (REUSE SECHUB DATA
 * enabled!)</u></b><br>
 *
 * In this scenario following is automatically initialized at start (old data
 * removed as well): <br>
 * <br>
 * a) <b> PDS integration test configuration is done automatically!</b> All
 * configurations from
 * 'sechub-integrationtest/src/main/resources/pds-config-integrationtest.json'
 * will be configured automatically!<br>
 * <br>
 * b) User and project data:
 *
 * <pre>
 * PROJECT_1_ is automatically created
 * USER_1, is automatically registered, created and assigned to project1
 * </pre>
 *
 * c) Execution profiles Following profiles are used inside this scenario
 *
 * <pre>
 * {@link IntegrationTestDefaultProfiles#PROFILE_8_PDS_WEBSCAN_SARIF}
 * {@link IntegrationTestDefaultProfiles#PROFILE_3_PDS_CODESCAN_SARIF}
 * </pre>
 *
 * @author Albert Tregnaghi
 *
 */
public class Scenario9 extends AbstractSecHubServerTestScenario implements PDSTestScenario, CleanScenario {

    /**
     * User 1 is registered on startup, also owner and user of {@link #PROJECT_1}
     */
    public static final TestUser USER_1 = createTestUser(Scenario9.class, "user1");

    /**
     * Project 1 is created on startup, and has {@link #USER_1} assigned
     */
    public static final TestProject PROJECT_1 = createTestProject(Scenario9.class, "project1");

    @Override
    protected void initializeTestData() {
        /* @formatter:off */
        initializer().
            createUser(USER_1).
            createProject(PROJECT_1, USER_1).
            addProjectIdsToDefaultExecutionProfile(PROFILE_3_PDS_CODESCAN_SARIF, PROJECT_1).
            addProjectIdsToDefaultExecutionProfile(PROFILE_8_PDS_WEBSCAN_SARIF, PROJECT_1).
            assignUserToProject(PROJECT_1, USER_1)
            ;
        /* @formatter:on */
    }

    @Override
    protected void waitForTestDataAvailable() {
        /* @formatter:off */
        initializer().
            waitUntilProjectExists(PROJECT_1).

            waitUntilUserExists(USER_1).

            waitUntilUserCanLogin(USER_1)

            ;
        /* @formatter:on */
    }
}