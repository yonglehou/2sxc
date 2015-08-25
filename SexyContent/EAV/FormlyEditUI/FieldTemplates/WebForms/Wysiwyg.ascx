﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Wysiwyg.ascx.cs" Inherits="ToSic.SexyContent.EAV.FormlyEditUI.FieldTemplates.WebForms.Wysiwyg" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.UI.WebControls" Assembly="DotNetNuke.Web" %>
<%@ Register TagPrefix="dnn" TagName="texteditor" Src="~/controls/texteditor.ascx" %>

<dnn:texteditor Height="400px" Width="100%" ID="Texteditor1" runat="server" EnableViewState="true" HtmlEncode="false" EnableResize="false" />

<script type="text/javascript">

	// Call this function from outside to register the actual bridge
	window.connectBridge = function(bridge) {
		window.bridge = bridge;
		$(document).ready(function() {
			initWysiwyg();
		});
	};

	function initWysiwyg() {

		var controller = {};
		var bridge = window.bridge;
		if (!bridge)
			throw "Bridge is null - should be set from outside of the iFrame";

		//bridge.onChanged("new value of wysiwyg control");
		bridge.setValue = function(v) {
			controller.setValue(v);
		};

		// Check if CKEDITOR is used
		if (window.CKEDITOR) {
			var instanceId = $(".editor").get(0).id;

			controller.setReadOnly = function (readOnlyState) {

				var setReadOnly = function (editor, readyOnlyState) {
					editor.setReadOnly(readOnlyState);

					if (readOnlyState)
						editor.document.getBody().setStyle('background-color', '#EEE');
					else
						editor.document.getBody().setStyle('background-color', '');
				};

				// If the instance is ready, run now - else wait
				if (CKEDITOR.instances[instanceId] && CKEDITOR.instances[instanceId].instanceReady)
					setReadOnly(CKEDITOR.instances[instanceId], readOnlyState);
				else
					CKEDITOR.on('instanceReady', function (ev) {
						if (!CKEDITOR.instances[instanceId])
							return;
						setReadOnly(CKEDITOR.instances[instanceId], readOnlyState);
					});

			};
			controller.setValue = function (value) {
				// If the instance is not yet ready, set textarea, else via CKEditor API
				if (!CKEDITOR.instances[instanceId] || !CKEDITOR.instances[instanceId].instanceReady)
					$("textarea.editor").val(value);
				else {
					var editor = CKEDITOR.instances[instanceId];
					editor.setData(value);
					// After setting the data, set readOnlyState again - else the background color will be reset
					Controller.SetReadOnly(editor.readOnly);
				}
			};
			controller.getValue = function () {
				// If instance is not yet ready, get HTML out of the textarea, else via CKEditor API
				if (!CKEDITOR.instances[instanceId] || !CKEDITOR.instances[instanceId].instanceReady)
					return $("textarea.editor").val();
				var editor = CKEDITOR.instances[instanceId]; //ev.editor;
				return editor.getData();
			};
		}
		else {
			// Use default Telerik RadEditor
			var editor = $find($(".RadEditor").get(0).id);
			editor.set_useClassicDialogs(true);

			controller.setReadOnly = function (readOnlyState) {
				// Bug DNN 7: Radeditor won't get disabled if this runs without timeout
				window.setTimeout(function () {
					// Bug in Radeditor: Must not set editable to the same value twice!
					if (!readOnlyState != editor.get_editable()) {
						editor.enableEditing(!readOnlyState);
						editor.set_editable(!readOnlyState);
						if (readOnlyState == true) editor.get_document().body.style.backgroundColor = "#EEE";
						else editor.get_document().body.style.backgroundColor = "";
					}
				}, 1);
			};
			controller.setValue = editor.set_html;
			controller.getValue = editor.get_html;

			editor.attachEventHandler('onselectionchange', function (e) {
				bridge.onChanged(editor.get_html());
			});
			//editor.attachEventHandler('onmousedown', function (e) {
			//	bridge.onChanged(editor.get_html());
			//});
			//$(document).on('keyup mouseup', function(e) {
			//	bridge.onChanged(editor.get_html());
			//});
		}
	}
	
</script>

<style type="text/css">
	/* Disable resizing of width */
	.RadEditor { width: 100%!important; }
</style>