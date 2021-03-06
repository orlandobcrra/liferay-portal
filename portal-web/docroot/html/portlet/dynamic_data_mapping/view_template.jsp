<%--
/**
 * Copyright (c) 2000-2012 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
--%>

<%@ include file="/html/portlet/dynamic_data_mapping/init.jsp" %>

<%
String tabs1 = ParamUtil.getString(request, "tabs1", "templates");

String backURL = ParamUtil.getString(request, "backURL");

long classNameId = ParamUtil.getLong(request, "classNameId");
long classPK = ParamUtil.getLong(request, "classPK");

DDMStructure structure = null;

long structureClassNameId = PortalUtil.getClassNameId(DDMStructure.class);

if ((classPK > 0) && (structureClassNameId == classNameId)) {
	structure = DDMStructureServiceUtil.getStructure(classPK);
}

PortletURL portletURL = renderResponse.createRenderURL();

portletURL.setParameter("struts_action", "/dynamic_data_mapping/view_template");
portletURL.setParameter("tabs1", tabs1);
portletURL.setParameter("backURL", backURL);
portletURL.setParameter("classNameId", String.valueOf(classNameId));
portletURL.setParameter("classPK", String.valueOf(classPK));
%>

<c:choose>
	<c:when test="<%= (structure != null) %>">
		<liferay-ui:header
			backURL="<%= backURL %>"
			title='<%= LanguageUtil.format(pageContext, (Validator.isNull(templateHeaderTitle) ? "templates-for-structure-x" : templateHeaderTitle), structure.getName(locale), false) %>'
		/>
	</c:when>
	<c:otherwise>
		<liferay-ui:header
			backURL="<%= backURL %>"
			title="display-styles"
		/>
	</c:otherwise>
</c:choose>

<liferay-util:include page="/html/portlet/dynamic_data_mapping/template_toolbar.jsp">
	<liferay-util:param name="classNameId" value="<%= String.valueOf(classNameId) %>" />
	<liferay-util:param name="classPK" value="<%= String.valueOf(classPK) %>" />
	<liferay-util:param name="backURL" value="<%= backURL %>" />
</liferay-util:include>

<aui:form action="<%= portletURL.toString() %>" method="post" name="fm">
	<aui:input name="<%= Constants.CMD %>" type="hidden" />
	<aui:input name="redirect" type="hidden" value="<%= portletURL.toString() %>" />
	<aui:input name="deleteTemplateIds" type="hidden" />

	<liferay-ui:search-container
		rowChecker="<%= new RowChecker(renderResponse) %>"
		searchContainer="<%= new TemplateSearch(renderRequest, portletURL) %>"
	>

		<liferay-ui:search-form
			page="/html/portlet/dynamic_data_mapping/template_search.jsp"
		/>

		<liferay-ui:search-container-results>
			<%@ include file="/html/portlet/dynamic_data_mapping/template_search_results.jspf" %>
		</liferay-ui:search-container-results>

		<liferay-ui:search-container-row
			className="com.liferay.portlet.dynamicdatamapping.model.DDMTemplate"
			keyProperty="templateId"
			modelVar="template"
		>

			<%
			String rowHREF = null;

			if (Validator.isNotNull(chooseCallback)) {
				StringBundler sb = new StringBundler(7);

				sb.append("javascript:Liferay.Util.getOpener()['");
				sb.append(HtmlUtil.escapeJS(chooseCallback));
				sb.append("']('");
				sb.append(template.getTemplateId());
				sb.append("', '");
				sb.append(HtmlUtil.escapeJS(template.getName(locale)));
				sb.append("', Liferay.Util.getWindow());");

				rowHREF = sb.toString();
			}
			else {
				PortletURL rowURL = renderResponse.createRenderURL();

				rowURL.setParameter("struts_action", "/dynamic_data_mapping/edit_template");
				rowURL.setParameter("redirect", currentURL);
				rowURL.setParameter("backURL", currentURL);
				rowURL.setParameter("groupId", String.valueOf(template.getGroupId()));
				rowURL.setParameter("templateId", String.valueOf(template.getTemplateId()));
				rowURL.setParameter("classNameId", String.valueOf(classNameId));
				rowURL.setParameter("classPK", String.valueOf(classPK));
				rowURL.setParameter("type", template.getType());

				rowHREF = rowURL.toString();
			}
			%>

			<liferay-ui:search-container-column-text
				href="<%= rowHREF %>"
				name="id"
				property="templateId"
			/>

			<liferay-ui:search-container-column-text
				href="<%= rowHREF %>"
				name="name"
				value="<%= LanguageUtil.get(pageContext, template.getName(locale)) %>"
			/>

			<c:if test="<%= Validator.isNull(templateTypeValue) %>">
				<liferay-ui:search-container-column-text
					href="<%= rowHREF %>"
					name="type"
					value="<%= LanguageUtil.get(pageContext, template.getType()) %>"
				/>
			</c:if>

			<liferay-ui:search-container-column-text
				href="<%= rowHREF %>"
				name="mode"
				value="<%= LanguageUtil.get(pageContext, template.getMode()) %>"
			/>

			<liferay-ui:search-container-column-text
				href="<%= rowHREF %>"
				name="language"
				value="<%= LanguageUtil.get(pageContext, template.getLanguage()) %>"
			/>

			<liferay-ui:search-container-column-text
				buffer="buffer"
				href="<%= rowHREF %>"
				name="modified-date"
			>

				<%
				buffer.append(dateFormatDateTime.format(template.getModifiedDate()));
				%>

			</liferay-ui:search-container-column-text>

			<liferay-ui:search-container-column-jsp
				align="right"
				path="/html/portlet/dynamic_data_mapping/template_action.jsp"
			/>
		</liferay-ui:search-container-row>

		<c:if test="<%= total > 0 %>">
			<aui:button-row>
				<aui:button cssClass="delete-templates-button" onClick='<%= renderResponse.getNamespace() + "deleteTemplates();" %>' value="delete" />
			</aui:button-row>

			<div class="separator"><!-- --></div>
		</c:if>

		<liferay-ui:search-iterator />
	</liferay-ui:search-container>
</aui:form>

<aui:script>
	Liferay.provide(
		window,
		'<portlet:namespace />deleteTemplates',
		function() {
			if (confirm('<%= UnicodeLanguageUtil.get(pageContext, "are-you-sure-you-want-to-delete-this") %>')) {
				document.<portlet:namespace />fm.method = "post";
				document.<portlet:namespace />fm.<portlet:namespace /><%= Constants.CMD %>.value = "<%= Constants.DELETE %>";
				document.<portlet:namespace />fm.<portlet:namespace />deleteTemplateIds.value = Liferay.Util.listCheckedExcept(document.<portlet:namespace />fm, "<portlet:namespace />allRowIds");

				submitForm(document.<portlet:namespace />fm, "<portlet:actionURL><portlet:param name="struts_action" value="/dynamic_data_mapping/edit_template" /></portlet:actionURL>");
			}
		},
		['liferay-util-list-fields']
	);
</aui:script>

<aui:script use="aui-base">
	var buttons = A.all('.delete-templates-button');

	if (buttons.size()) {
		var toggleDisabled = A.bind(Liferay.Util.toggleDisabled, Liferay.Util, ':button');

		var resultsGrid = A.one('.results-grid');

		if (resultsGrid) {
			resultsGrid.delegate(
				'click',
				function(event) {
					var disabled = (resultsGrid.one(':checked') == null);

					toggleDisabled(disabled);
				},
				':checkbox'
			);
		}

		toggleDisabled(true);
	}
</aui:script>