/*******************************************************************************
* Copyright (c) 2012 Harman International (http://www.harman.com).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*******************************************************************************/
package org.franca.core.framework;

import org.franca.core.franca.FModel;

public interface IFrancaConnector extends IModelPersistenceManager {

	// conversion to/from Franca models
	public FModel toFranca (IModelContainer model);
	public IModelContainer fromFranca (FModel fmodel);
}
