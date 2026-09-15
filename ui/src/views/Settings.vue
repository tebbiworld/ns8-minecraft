<!--
  Copyright (C) 2026 tebbi
  SPDX-License-Identifier: GPL-3.0-or-later
-->
<template>
  <cv-grid fullWidth>
    <cv-row>
      <cv-column class="page-title"><h2>{{ $t("settings.title") }}</h2></cv-column>
    </cv-row>
    <cv-row v-if="error.getConfiguration">
      <cv-column>
        <NsInlineNotification kind="error" :title="$t('action.get-configuration')" :description="error.getConfiguration" :showCloseButton="false" />
      </cv-column>
    </cv-row>
    <cv-row>
      <cv-column>
        <cv-tile light>
          <!-- Live state -->
          <NsInlineNotification
            v-if="!loading.getConfiguration"
            :kind="server_running ? (server_version ? 'success' : 'warning') : 'info'"
            :title="serverStatusTitle"
            :description="$t('settings.connect_desc', { java: javaAddress, bedrock: bedrockAddress })"
            :showCloseButton="false"
            class="info-tile"
          />
          <cv-form @submit.prevent="configureModule">
            <!-- Server -->
            <h4 class="section">{{ $t("settings.server_section") }}</h4>
            <cv-toggle value="eula_accepted" :label="$t('settings.eula_accepted')" v-model="eula_accepted" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <div class="bx--form__helper-text">{{ $t("settings.eula_helper") }}</div>
            <div v-if="error.eula_accepted" class="bx--form-requirement error-text">{{ $t(error.eula_accepted) }}</div>
            <cv-dropdown :label="$t('settings.server_type')" v-model="server_type" :helper-text="$t('settings.server_type_helper')" :disabled="busy" class="field">
              <cv-dropdown-item value="PAPER">{{ $t("settings.type_paper") }}</cv-dropdown-item>
              <cv-dropdown-item value="VANILLA">{{ $t("settings.type_vanilla") }}</cv-dropdown-item>
              <cv-dropdown-item value="FABRIC">{{ $t("settings.type_fabric") }}</cv-dropdown-item>
            </cv-dropdown>
            <cv-text-input :label="$t('settings.version')" v-model.trim="version" :placeholder="$t('settings.version_placeholder')" :helper-text="$t('settings.version_helper')" :disabled="busy" :invalid-message="$t(error.version)" ref="version" class="field"></cv-text-input>
            <cv-number-input :label="$t('settings.memory_mb')" v-model="memory_mb" :min="512" :max="262144" :step="256" :helper-text="$t('settings.memory_mb_helper')" :disabled="busy" :invalid-message="$t(error.memory_mb)" ref="memory_mb" class="field"></cv-number-input>
            <cv-number-input :label="$t('settings.game_port')" v-model="game_port" :min="1024" :max="65535" :helper-text="$t('settings.game_port_helper')" :disabled="busy" :invalid-message="$t(error.game_port)" ref="game_port" class="field"></cv-number-input>
            <cv-text-input :label="$t('settings.timezone')" v-model.trim="timezone" :placeholder="$t('settings.timezone_placeholder')" :helper-text="$t('settings.timezone_helper')" :disabled="busy" class="field"></cv-text-input>

            <!-- World -->
            <h4 class="section">{{ $t("settings.world_section") }}</h4>
            <cv-text-input :label="$t('settings.motd')" v-model="motd" :placeholder="$t('settings.motd_placeholder')" :helper-text="$t('settings.motd_helper')" :disabled="busy" class="field"></cv-text-input>
            <cv-dropdown :label="$t('settings.gamemode')" v-model="gamemode" :disabled="busy" class="field">
              <cv-dropdown-item value="survival">{{ $t("settings.gm_survival") }}</cv-dropdown-item>
              <cv-dropdown-item value="creative">{{ $t("settings.gm_creative") }}</cv-dropdown-item>
              <cv-dropdown-item value="adventure">{{ $t("settings.gm_adventure") }}</cv-dropdown-item>
              <cv-dropdown-item value="spectator">{{ $t("settings.gm_spectator") }}</cv-dropdown-item>
            </cv-dropdown>
            <cv-dropdown :label="$t('settings.difficulty')" v-model="difficulty" :disabled="busy" class="field">
              <cv-dropdown-item value="peaceful">{{ $t("settings.df_peaceful") }}</cv-dropdown-item>
              <cv-dropdown-item value="easy">{{ $t("settings.df_easy") }}</cv-dropdown-item>
              <cv-dropdown-item value="normal">{{ $t("settings.df_normal") }}</cv-dropdown-item>
              <cv-dropdown-item value="hard">{{ $t("settings.df_hard") }}</cv-dropdown-item>
            </cv-dropdown>
            <cv-number-input :label="$t('settings.max_players')" v-model="max_players" :min="1" :max="1000" :disabled="busy" class="field"></cv-number-input>
            <cv-toggle value="pvp" :label="$t('settings.pvp')" v-model="pvp" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <cv-toggle value="online_mode" :label="$t('settings.online_mode')" v-model="online_mode" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <div class="bx--form__helper-text">{{ $t("settings.online_mode_helper") }}</div>
            <cv-text-input :label="$t('settings.seed')" v-model.trim="seed" :helper-text="$t('settings.seed_helper')" :disabled="busy" class="field"></cv-text-input>

            <!-- Players -->
            <h4 class="section">{{ $t("settings.players_section") }}</h4>
            <cv-text-area :label="$t('settings.whitelist')" v-model="whitelist_text" :placeholder="$t('settings.whitelist_placeholder')" :helper-text="$t('settings.whitelist_helper')" :disabled="busy" :invalid-message="$t(error.whitelist)" ref="whitelist" rows="4" class="field"></cv-text-area>
            <cv-text-area :label="$t('settings.ops')" v-model="ops_text" :placeholder="$t('settings.ops_placeholder')" :helper-text="$t('settings.ops_helper')" :disabled="busy" :invalid-message="$t(error.ops)" ref="ops" rows="3" class="field"></cv-text-area>

            <!-- Bedrock -->
            <h4 class="section">{{ $t("settings.bedrock_section") }}</h4>
            <cv-toggle value="bedrock_enabled" :label="$t('settings.bedrock_enabled')" v-model="bedrock_enabled" :disabled="busy" class="toggle">
              <template slot="text-left">{{ $t("settings.disabled") }}</template>
              <template slot="text-right">{{ $t("settings.enabled") }}</template>
            </cv-toggle>
            <div class="bx--form__helper-text">{{ $t("settings.bedrock_helper") }}</div>
            <div v-if="error.bedrock_enabled" class="bx--form-requirement error-text">{{ $t(error.bedrock_enabled) }}</div>
            <cv-number-input v-if="bedrock_enabled" :label="$t('settings.bedrock_port')" v-model="bedrock_port" :min="1024" :max="65535" :helper-text="$t('settings.bedrock_port_helper')" :disabled="busy" :invalid-message="$t(error.bedrock_port)" ref="bedrock_port" class="field"></cv-number-input>

            <!-- Advanced -->
            <h4 class="section">{{ $t("settings.advanced_section") }}</h4>
            <cv-text-area :label="$t('settings.extra_env')" v-model="extra_env_text" :placeholder="$t('settings.extra_env_placeholder')" :helper-text="$t('settings.extra_env_helper')" :disabled="busy" :invalid-message="$t(error.extra_env)" ref="extra_env" rows="4" class="field"></cv-text-area>

            <cv-row v-if="error.configureModule">
              <cv-column>
                <NsInlineNotification kind="error" :title="$t('action.configure-module')" :description="error.configureModule" :showCloseButton="false" />
              </cv-column>
            </cv-row>
            <NsButton kind="primary" :icon="Save20" :loading="loading.configureModule" :disabled="busy">{{ $t("settings.save") }}</NsButton>
          </cv-form>
        </cv-tile>
      </cv-column>
    </cv-row>

    <!-- Server console -->
    <cv-row>
      <cv-column>
        <cv-tile light>
          <h4 class="section-first">{{ $t("settings.command_section") }}</h4>
          <cv-form @submit.prevent="runCommand">
            <cv-text-input :label="$t('settings.command')" v-model.trim="command" :placeholder="$t('settings.command_placeholder')" :helper-text="$t('settings.command_helper')" :disabled="loading.runCommand || !server_running" class="field"></cv-text-input>
            <NsButton kind="secondary" :icon="Send20" :loading="loading.runCommand" :disabled="loading.runCommand || !server_running || !command">{{ $t("settings.run_command") }}</NsButton>
          </cv-form>
          <NsInlineNotification v-if="error.runCommand" kind="error" :title="$t('action.run-command')" :description="error.runCommand" :showCloseButton="false" class="info-tile" />
          <div v-if="command_output !== null" class="field">
            <div class="bx--label">{{ $t("settings.command_output") }}</div>
            <pre class="console">{{ command_output || $t("settings.command_no_output") }}</pre>
          </div>
        </cv-tile>
      </cv-column>
    </cv-row>
  </cv-grid>
</template>

<script>
import to from "await-to-js";
import { mapState } from "vuex";
import { QueryParamService, UtilService, TaskService, IconService, PageTitleService } from "@nethserver/ns8-ui-lib";
import Send20 from "@carbon/icons-vue/es/send/20";

const NAME_RE = /^[A-Za-z0-9_]{3,16}$/;
const VERSION_RE = /^(LATEST|SNAPSHOT|[0-9][0-9A-Za-z.-]*)$/;
const ENV_RE = /^[A-Z][A-Z0-9_]*=/;

export default {
  name: "Settings",
  mixins: [TaskService, IconService, UtilService, QueryParamService, PageTitleService],
  pageTitle() {
    return this.$t("settings.title") + " - " + this.appName;
  },
  data() {
    return {
      q: { page: "settings" },
      urlCheckInterval: null,
      Send20,
      eula_accepted: false,
      server_type: "PAPER",
      version: "LATEST",
      memory_mb: 2048,
      game_port: 25565,
      bedrock_enabled: false,
      bedrock_port: 19132,
      motd: "",
      gamemode: "survival",
      difficulty: "normal",
      max_players: 20,
      pvp: true,
      online_mode: true,
      whitelist_text: "",
      ops_text: "",
      seed: "",
      timezone: "UTC",
      extra_env_text: "",
      server_running: false,
      server_version: "",
      players_online: null,
      players_max: null,
      node_ip: "",
      command: "",
      command_output: null,
      loading: { getConfiguration: false, configureModule: false, runCommand: false },
      error: {
        getConfiguration: "", configureModule: "", runCommand: "",
        eula_accepted: "", version: "", memory_mb: "", game_port: "", bedrock_enabled: "", bedrock_port: "", whitelist: "", ops: "", extra_env: "",
      },
    };
  },
  computed: {
    ...mapState(["instanceName", "core", "appName"]),
    busy() {
      return this.loading.getConfiguration || this.loading.configureModule;
    },
    whitelist() {
      return this.splitLines(this.whitelist_text);
    },
    ops() {
      return this.splitLines(this.ops_text);
    },
    extra_env() {
      return this.splitLines(this.extra_env_text);
    },
    javaAddress() {
      return `${this.node_ip || "<node>"}:${this.game_port}`;
    },
    bedrockAddress() {
      return this.bedrock_enabled ? `${this.node_ip || "<node>"}:${this.bedrock_port} (UDP)` : this.$t("settings.connect_bedrock_off");
    },
    serverStatusTitle() {
      if (!this.server_running) return this.$t("settings.status_stopped");
      if (!this.server_version) return this.$t("settings.status_starting");
      return this.$t("settings.status_running", { version: this.server_version, online: this.players_online, max: this.players_max });
    },
  },
  beforeRouteEnter(to, from, next) {
    next((vm) => {
      vm.watchQueryData(vm);
      vm.urlCheckInterval = vm.initUrlBindingForApp(vm, vm.q.page);
    });
  },
  beforeRouteLeave(to, from, next) {
    clearInterval(this.urlCheckInterval);
    next();
  },
  created() {
    this.getConfiguration();
  },
  methods: {
    splitLines(text) {
      return text
        .split(/\r?\n/)
        .map((p) => p.trim())
        .filter((p) => p.length > 0);
    },
    async getConfiguration() {
      this.loading.getConfiguration = true;
      this.error.getConfiguration = "";
      const taskAction = "get-configuration";
      const eventId = this.getUuid();
      this.core.$root.$once(`${taskAction}-aborted-${eventId}`, this.getConfigurationAborted);
      this.core.$root.$once(`${taskAction}-completed-${eventId}`, this.getConfigurationCompleted);
      const res = await to(this.createModuleTaskForApp(this.instanceName, { action: taskAction, extra: { title: this.$t("action." + taskAction), isNotificationHidden: true, eventId } }));
      const err = res[0];
      if (err) {
        this.error.getConfiguration = this.getErrorMessage(err);
        this.loading.getConfiguration = false;
      }
    },
    getConfigurationAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.getConfiguration = this.$t("error.generic_error");
      this.loading.getConfiguration = false;
    },
    getConfigurationCompleted(taskContext, taskResult) {
      this.loading.getConfiguration = false;
      const c = taskResult.output;
      this.eula_accepted = !!c.eula_accepted;
      this.server_type = c.server_type || "PAPER";
      this.version = c.version || "LATEST";
      this.memory_mb = c.memory_mb || 2048;
      this.game_port = c.game_port || 25565;
      this.bedrock_enabled = !!c.bedrock_enabled;
      this.bedrock_port = c.bedrock_port || 19132;
      this.motd = c.motd || "";
      this.gamemode = c.gamemode || "survival";
      this.difficulty = c.difficulty || "normal";
      this.max_players = c.max_players || 20;
      this.pvp = c.pvp !== undefined ? !!c.pvp : true;
      this.online_mode = c.online_mode !== undefined ? !!c.online_mode : true;
      this.whitelist_text = (c.whitelist || []).join("\n");
      this.ops_text = (c.ops || []).join("\n");
      this.seed = c.seed || "";
      this.timezone = c.timezone || "UTC";
      this.extra_env_text = (c.extra_env || []).join("\n");
      this.server_running = !!c.server_running;
      this.server_version = c.server_version || "";
      this.players_online = c.players_online;
      this.players_max = c.players_max;
      this.node_ip = c.node_ip || "";
    },
    validateConfigureModule() {
      this.clearErrors(this);
      let ok = true;
      const fail = (field, msg) => {
        this.error[field] = msg;
        if (ok && this.$refs[field]) this.focusElement(field);
        ok = false;
      };
      if (!this.eula_accepted) fail("eula_accepted", "settings.eula_required");
      if (!VERSION_RE.test(this.version || "LATEST")) fail("version", "settings.invalid_version");
      if (this.whitelist.some((n) => !NAME_RE.test(n))) fail("whitelist", "settings.invalid_player_name");
      if (this.ops.some((n) => !NAME_RE.test(n))) fail("ops", "settings.invalid_player_name");
      if (this.extra_env.some((e) => !ENV_RE.test(e))) fail("extra_env", "settings.invalid_extra_env");
      if (this.bedrock_enabled && this.server_type !== "PAPER") fail("bedrock_enabled", "settings.bedrock_requires_paper");
      return ok;
    },
    configureModuleValidationFailed(validationErrors) {
      this.loading.configureModule = false;
      let focusSet = false;
      for (const e of validationErrors) {
        if (e.field !== "(root)") {
          const detail = e.value && typeof e.value === "string" ? ` (${e.value})` : "";
          this.error[e.field] = this.$t("settings." + e.error) + detail;
          if (!focusSet && this.$refs[e.field]) {
            this.focusElement(e.field);
            focusSet = true;
          }
        }
      }
    },
    async configureModule() {
      if (!this.validateConfigureModule()) return;
      this.loading.configureModule = true;
      const taskAction = "configure-module";
      const eventId = this.getUuid();
      this.core.$root.$once(`${taskAction}-aborted-${eventId}`, this.configureModuleAborted);
      this.core.$root.$once(`${taskAction}-validation-failed-${eventId}`, this.configureModuleValidationFailed);
      this.core.$root.$once(`${taskAction}-completed-${eventId}`, this.configureModuleCompleted);
      const data = {
        eula_accepted: this.eula_accepted,
        server_type: this.server_type,
        version: this.version || "LATEST",
        memory_mb: Number(this.memory_mb),
        game_port: Number(this.game_port),
        bedrock_enabled: this.bedrock_enabled,
        bedrock_port: Number(this.bedrock_port),
        motd: this.motd,
        gamemode: this.gamemode,
        difficulty: this.difficulty,
        max_players: Number(this.max_players),
        pvp: this.pvp,
        online_mode: this.online_mode,
        whitelist: this.whitelist,
        ops: this.ops,
        seed: this.seed,
        timezone: this.timezone || "UTC",
        extra_env: this.extra_env,
      };
      const res = await to(this.createModuleTaskForApp(this.instanceName, {
        action: taskAction,
        data,
        extra: { title: this.$t("settings.configure_instance", { instance: this.instanceName }), description: this.$t("common.processing"), eventId },
      }));
      const err = res[0];
      if (err) {
        this.error.configureModule = this.getErrorMessage(err);
        this.loading.configureModule = false;
      }
    },
    configureModuleAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.configureModule = this.$t("error.generic_error");
      this.loading.configureModule = false;
    },
    configureModuleCompleted() {
      this.loading.configureModule = false;
      this.getConfiguration();
    },
    async runCommand() {
      if (!this.command) return;
      this.loading.runCommand = true;
      this.error.runCommand = "";
      this.command_output = null;
      const taskAction = "run-command";
      const eventId = this.getUuid();
      this.core.$root.$once(`${taskAction}-aborted-${eventId}`, this.runCommandAborted);
      this.core.$root.$once(`${taskAction}-completed-${eventId}`, this.runCommandCompleted);
      const res = await to(this.createModuleTaskForApp(this.instanceName, {
        action: taskAction,
        data: { command: this.command },
        extra: { title: this.$t("action." + taskAction), isNotificationHidden: true, eventId },
      }));
      const err = res[0];
      if (err) {
        this.error.runCommand = this.getErrorMessage(err);
        this.loading.runCommand = false;
      }
    },
    runCommandAborted(taskResult, taskContext) {
      console.error(`${taskContext.action} aborted`, taskResult);
      this.error.runCommand = this.$t("error.generic_error");
      this.loading.runCommand = false;
    },
    runCommandCompleted(taskContext, taskResult) {
      this.loading.runCommand = false;
      this.command_output = (taskResult.output && taskResult.output.output) || "";
      this.getConfiguration();
    },
  },
};
</script>

<style scoped lang="scss">
@import "../styles/carbon-utils";
.field { margin-top: $spacing-06; }
.toggle { margin-top: $spacing-06; }
.info-tile { margin-top: $spacing-06; }
.section { margin-top: $spacing-07; margin-bottom: $spacing-03; }
.section-first { margin-bottom: $spacing-03; }
.error-text { display: block; color: #da1e28; margin-top: $spacing-03; }
.console { font-family: monospace; white-space: pre-wrap; background: #f4f4f4; padding: $spacing-05; margin-top: $spacing-03; }
</style>
