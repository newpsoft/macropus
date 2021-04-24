.pragma library
.import "../qml/extension.js" as Extension

function requireModel(model, propertyName) {
	if (!model)
		throw "No model is given to fiddle."
	if (!propertyName)
		throw "No property name is given to fiddle."
}

function fiddleCheck(checkBox, model, propertyName, compare) {
	var expectModel = function () {
		if (model && propertyName)
			compare(model[propertyName], checkBox.checked)
	}

	checkBox.checked = true
	compare(checkBox.checked, true)
	expectModel()

	checkBox.checked = false
	compare(checkBox.checked, false)
	expectModel()
}

function fiddleCheckModel(checkBox, model, propertyName, compare) {
	requireModel(model, propertyName)

	model[propertyName] = true
	compare(model[propertyName], true)
	compare(checkBox.checked, true)

	model[propertyName] = false
	compare(model[propertyName], false)
	compare(checkBox.checked, false)
}

function fiddleText(editText, model, propertyName, compare) {
	var expectModel = function () {
		if (model && propertyName)
			compare(model[propertyName], editText.text)
	}

	editText.text = "fiddleText"
	compare(editText.text, "fiddleText")
	expectModel()

	editText.text = ""
	compare(editText.text, "")
	expectModel()
}

function fiddleTextModel(editText, model, propertyName, compare) {
	requireModel(model, propertyName)

	model[propertyName] = "fiddleTextModel"
	compare(model[propertyName], "fiddleTextModel")
	compare(editText.text, "fiddleTextModel")

	model[propertyName] = ""
	compare(model[propertyName], "")
	compare(editText.text, "")
}

function fiddleCombo(comboBox, itemModel, model, propertyName, compare) {
	var expectModel = () => {
		if (model && propertyName) {
			var element = comboBox.model[comboBox.currentIndex]
			if (!element) {
				return
			} else if (Extension.isObjectExplicit(element)) {
				compare(model[propertyName], element[propertyName])
			} else {
				compare(model[propertyName], comboBox.currentIndex)
			}
		}
	}
	var activateMe = index => {
		comboBox.currentIndex = index
		comboBox.activated(comboBox.currentIndex)
	}

	/* Model may not have property yet, and currentIndexChanged SHOULD set
	 * the property in the model. */
	comboBox.currentIndexChanged()
	comboBox.activated(comboBox.currentIndex)

	// All valid
	for (var i in itemModel) {
		i = Number(i)
		activateMe(i)
		compare(comboBox.currentIndex, i)
		expectModel()
	}

	// Edge case
	activateMe(itemModel.length)
	expectModel()

	// Definitely invalid
	activateMe(0xFF)
	expectModel()

	// -1 sets empty text
	activateMe(-1)
	compare(comboBox.currentIndex, -1)
	expectModel()
}

// TODO Invalid when combo model is not list of strings
function fiddleComboModel(comboBox, itemModel, model, propertyName, compare) {
	requireModel(model, propertyName)

	for (var i in itemModel) {
		i = Number(i)
		model[propertyName] = i
		compare(comboBox.currentIndex, i)
	}

	// edge
	model[propertyName] = itemModel.length
	compare(comboBox.currentIndex, itemModel.length)

	// definitely invalid
	model[propertyName] = 0xFF
	compare(comboBox.currentIndex, 0xFF)

	// -1 sets empty text
	model[propertyName] = -1
	compare(comboBox.currentIndex, -1)
	compare(comboBox.currentText, "")
}

function fiddleSpin(spinBox, model, propertyName, compare) {
	var expectModel = function () {
		if (model && propertyName)
			compare(model[propertyName], spinBox.value)
	}

	spinBox.value = spinBox.from - 1
	compare(spinBox.value, spinBox.from)
	expectModel()

	spinBox.value = spinBox.from
	compare(spinBox.value, spinBox.from)
	expectModel()

	spinBox.value = 0
	compare(spinBox.value, 0)
	expectModel()

	spinBox.value = spinBox.to
	compare(spinBox.value, spinBox.to)
	expectModel()

	spinBox.value = spinBox.to + 1
	compare(spinBox.value, spinBox.to)
	expectModel()
}

function fiddleSpinModel(spinBox, model, propertyName, compare) {
	requireModel(model, propertyName)

	model[propertyName] = spinBox.from
	compare(model[propertyName], spinBox.from)
	compare(spinBox.value, spinBox.from)

	model[propertyName] = 0
	compare(model[propertyName], 0)
	compare(spinBox.value, 0)

	model[propertyName] = spinBox.to
	compare(model[propertyName], spinBox.to)
	compare(spinBox.value, spinBox.to)
}
